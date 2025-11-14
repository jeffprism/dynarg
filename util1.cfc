component {
	/*

	Author: Jeff Mcclain 11/14/25

        Calculates a web-relative URL path (using ../ segments) from one URL-based
        path under the webroot to another. This function does not use filesystem
        paths and does not depend on physical directory structure. It operates
        strictly on URL-style paths, making it safe for use with <cfinclude>,
        CFC invocation URLs, links, AJAX calls, and routing.

        Examples:
            getWebRelativePath("/scripts/work/", "/cfc/obj/dashboard/")
                 "../../cfc/obj/dashboard/"

            getWebRelativePath("/scripts/work/", "/cfc/obj/dashboard/test.cfc")
                 "../../cfc/obj/dashboard/test.cfc"

            getWebRelativePath("/scripts/work/", "/cfc/obj/dashboard/test.cfc?method=foo")
                 "../../cfc/obj/dashboard/test.cfc?method=foo"

        Behavior:
            - Determines the correct number of ../ path segments dynamically.
            - Detects whether the target is a folder or a file:
                . Files (.cfm, .cfc, etc.) do NOT receive a trailing slash.
                . Folders always receive a trailing slash.
            - Preserves any query string (?method=foo).
            - Works correctly regardless of how deeply nested the source or target
            directories are.

        Parameters:
            from - The starting URL path (directory) under the webroot.
            to   - The target URL path (file or directory) under the webroot.

        Returns:
            A clean, correct web-relative URL that points from `from` to `to`.


	*/
	public string function getWebRelativePath(required string from, required string to) output=false {
		var fromPath = replace(arguments.from, "\", "/", "all");
		var toRaw    = replace(arguments.to,   "\", "/", "all");
		var toPath   = "";
		var qs       = "";
		var qPos     = 0;
		var fromParts = [];
		var toParts   = [];
		var i         = 1;
		var upLevels  = 0;
		var rel       = "";
		var rest      = [];
		var lastSegment = "";
		var baseSegment = "";
		var isFile    = false;
		//  normalize 
		fromPath = "/" & rereplace(fromPath, "^/+", "");
		toRaw    = "/" & rereplace(toRaw,    "^/+", "");
		fromPath = rereplace(fromPath, "/+$", "");
		toRaw    = rereplace(toRaw,    "/+$", "");
		//  extract query string properly for Adobe CF 
		qPos = find("?", toRaw);
		if ( qPos > 0 ) {
			//  correct MID usage: mid(string, start, length) 
			qs    = mid(toRaw, qPos, len(toRaw) - qPos + 1);
			toPath = left(toRaw, qPos - 1);
		} else {
			toPath = toRaw;
		}
		//  split paths 
		fromParts = listToArray(fromPath, "/");
		toParts   = listToArray(toPath,   "/");
		//  find common prefix 
		while ( condition="i <= arrayLen(fromParts) && i <= arrayLen(toParts) && fromParts[i] == toParts[i]" ) {
			i++;
		}
		//  how many "../" are needed? 
		upLevels = arrayLen(fromParts) - (i - 1);
		rel = "";
		for ( x=1 ; x<=upLevels ; x++ ) {
			rel &= "../";
		}
		//  remaining path 
		rest = arraySlice(toParts, i, arrayLen(toParts) - (i - 1));
		if ( arrayLen(rest) ) {
			lastSegment = rest[arrayLen(rest)];
			//  detect if last segment is a file (has .ext) 
			isFile = reFind("\.[A-Za-z0-9]+$", lastSegment) > 0;
			rel &= arrayToList(rest, "/");
			if ( !isFile ) {
				//  folder gets a trailing slash 
				rel &= "/";
			}
		}
		//  append query string back 
		if ( len(qs) ) {
			rel &= qs;
		}
		return rel;
	}
	/* 
			Author: Jeff Mcclain 11/14/25
			
		Convenience wrapper for getWebRelativePath() that automatically calculates
		the relative URL path from the *current executing template* to the target URL.

		Usage Example:
			<cfset utilObj = new cfc.util()>
			<cfset rel = utilObj.fromHere("/cfc/obj/dashboard/test.cfc?method=foo")>
			<cfoutput>#rel#</cfoutput>

		If this code runs from:
			/scripts/work/test.cfm

		The result will be:
			../../cfc/obj/dashboard/test.cfc?method=foo

		Behavior:
			- If the target ends with a file (.cfm or .cfc), no trailing slash is added.
			- If the target is a folder (e.g. "/cfc/obj/dashboard"), a trailing "/" is added.
			- The result is correct regardless of how deeply nested the current file is
			or how deep the target path is.

		Returns:
			The correct relative URL (using ../ segments) from the current request's
			directory to the specified target URL.
	*/

	public string function fromHere(required string toURL) output=false {
		return getWebRelativePath( getDirectoryFromPath(CGI.SCRIPT_NAME), arguments.toURL );
	}

}
