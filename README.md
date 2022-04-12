# dynarg

I encountered an issue where I had to send to a webservice only fields that are changed on a form. This meant I did not have a static argument to send to a function. So, I created an array and filled it dynamically. Sent that to the function with the static session id. 

Code is uploaded.

The cfm sets up the array and sends it to the function and returns the output.

<cfscript>

		    fieldList = ArrayNew(2);
		    fieldList[1][1] = "First Name";
		    fieldList[1][2] = "Tim";
		    fieldList[2][1] = "Last Name";
		    fieldList[2][2] = "Johnson";
		    fieldList[3][1] = "clientId";
		    fieldList[3][2] = 2;
		    // writeDump(fieldList); debug code if you want to see the array before the cfc processes it
		    testdyn = CreateObject("dynarg");
		    test = testdyn.dynarg(sessionId=23,dynarg=fieldList);

		    writeOutput(test);
</cfscript>

The cfc has one function that just makes the jSon for the web call.

component {

	remote function dynarg(sessionId, dynarg) {
		API_Request = '{';
		for ( itm in arguments.dynarg ) {
			API_Request = '#API_Request##itm[1]#: #itm[2]#,';
		}
		API_Request = '#API_Request# SessionID: #arguments.sessionID#}';
		return #API_Request#;
	}

}

Output looks like this.

{First Name: Tim,Last Name: Johnson,clientId: 2, SessionID: 23}
