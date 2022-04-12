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
	

