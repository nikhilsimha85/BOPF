function initModel() {
	var sUrl = "/sap/opu/odata/sap/ZUS_TM_BOPF_DETAILS_SRV/";
	var oModel = new sap.ui.model.odata.ODataModel(sUrl, true);
	sap.ui.getCore().setModel(oModel);
}