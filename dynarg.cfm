<cfscript>

		    fieldList = ArrayNew(2);
		    fieldList[1][1] = "First Name";
		    fieldList[1][2] = "Tim";
		    fieldList[2][1] = "Last Name";
		    fieldList[2][2] = "Johnson";
		    fieldList[3][1] = "clientId";
		    fieldList[3][2] = 2;
		    // writeDump(fieldList);
		    testdyn = CreateObject("dynarg");
		    test = testdyn.dynarg(sessionId=23,dynarg=fieldList);

		    writeOutput(test);
</cfscript>