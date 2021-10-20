sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/ui/core/routing/History",
	"sap/ui/model/Filter",
	"sap/ui/model/FilterOperator",
	"sap/m/MessageToast"
], function (Controller, History, Filter, FilterOperator, MessageToast) {
	"use strict";

	return Controller.extend("bopf.BOPFHelp.controller.TableDetails", {

		/**
		 * Called when a controller is instantiated and its View controls (if available) are already created.
		 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
		 * @memberOf bopf.zus_tm_bopf.view.TableDetails
		 */
		onInit: function () {
			var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
			oRouter.getRoute("TableDetails").attachPatternMatched(this._onRouteMatched, this);
		},
		_onRouteMatched: function (oEvent) {

			var TableName = oEvent.getParameter("arguments").parameter;
			TableName = TableName.replaceAll("!", "/");
			var aFilters = [];
			var oTable = this.byId("idTable");
			var nameFilter = new Filter("Tablename", FilterOperator.EQ, TableName);
			aFilters.push(nameFilter);
			oTable.getBinding("items").filter(aFilters);
			oTable.getBinding("items").attachDataReceived(function (oEvt) {
				if (oEvt.getParameter("data").results.length === 0) {
					MessageToast.show("Invalid Table name", {
						duration: 2000,
						width: "15rem"
					});
				}
			});
			oTable.getBinding("items").resume();
		},

		onNavBack: function (oEvent) {
			var oHistory = History.getInstance();
			var sPreviousHash = oHistory.getPreviousHash();

			if (sPreviousHash !== undefined) {
				window.history.go(-1);
			} else {
				var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
				oRouter.navTo("TargetMain", true);
			}
		}

		/**
		 * Similar to onAfterRendering, but this hook is invoked before the controller's View is re-rendered
		 * (NOT before the first rendering! onInit() is used for that one!).
		 * @memberOf bopf.zus_tm_bopf.view.TableDetails
		 */
		//	onBeforeRendering: function() {
		//
		//	},

		/**
		 * Called when the View has been rendered (so its HTML is part of the document). Post-rendering manipulations of the HTML could be done here.
		 * This hook is the same one that SAPUI5 controls get after being rendered.
		 * @memberOf bopf.zus_tm_bopf.view.TableDetails
		 */
		//	onAfterRendering: function() {
		//
		//	},

		/**
		 * Called when the Controller is destroyed. Use this one to free resources and finalize activities.
		 * @memberOf bopf.zus_tm_bopf.view.TableDetails
		 */
		//	onExit: function() {
		//
		//	}

	});

});