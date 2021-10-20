sap.ui.define([
	"sap/ui/core/mvc/Controller",
	"sap/ui/model/Filter",
	"sap/ui/core/Fragment",
	"sap/ui/model/FilterOperator",
	"sap/m/MessageToast"
], function (Controller, Filter, Fragment, FilterOperator, MessageToast) {
	"use strict";
	return Controller.extend("bopf.BOPFHelp.controller.Main", {
		onInit: function () {
			//this.byId("treeTable").getBinding("rows").suspend(true);
		},
		onValueHelpRequest: function (oEvent) {
			if (!this.oValueHelpDialog) {
				this.oValueHelpDialog = sap.ui.xmlfragment(
					"bopf.BOPFHelp.fragment.Help", this);
				this.getView().addDependent(this.oValueHelpDialog);
			}
			this.oValueHelpDialog.open();
		},

		onValueHelpSearch: function (oEvent) {
			var sValue = oEvent.getParameter("value");
			var oFilter1 = new Filter("BO_NAME", "Contains", sValue);
			var oFilter2 = new Filter("DESCRIPTION", "Contains", sValue);
			var oBinding = oEvent.getSource().getBinding("items");
			oBinding.filter([oFilter1, oFilter2]);
		},
		onValueHelpClose: function (oEvent) {
			var oSelectedItem = oEvent.getParameter("selectedItem"),
				oInput = this.byId("BOPFInput");
			if (!oSelectedItem) {
				oInput.resetProperty("value");
				return;
			}
			oInput.setValue(oSelectedItem.getTitle());
			this.onSubmit(oSelectedItem);

		},
		onSubmit: function (oEvent) {
			if (typeof oEvent.getParameters === "function") {
				var BOPFName = oEvent.getParameter("value");
			}
			if (!BOPFName && typeof oEvent.getParameters === "function") {
				BOPFName = oEvent.getParameter("selectedItem").getText();
			}
			if (!BOPFName && typeof oEvent.getTitle === "function") {
				BOPFName = oEvent.getTitle();
			}
			var oTable = this.byId("treeTable");
			var aFilters = [];
			var nameFilter = new Filter("Name", FilterOperator.EQ, BOPFName);
			aFilters.push(nameFilter);
			var that = this;
			//oTable.filter(aFilters);
			var oModel = new sap.ui.model.odata.v2.ODataModel("/sap/opu/odata/sap/ZUS_TM_BOPF_DETAILS_SRV/");
			oModel.read("/HierarchySet", {
				filters: aFilters,
				success: function (oData) {
					var flattenedData = that.flatten(oData.results);
					var oTable = that.byId("treeTable");
					if (oData.results.length === 0) {
						MessageToast.show("Invalid BOPF name", {
							duration: 2000,
							width: "15rem"
						});
					} else {
						var oModel1 = new sap.ui.model.json.JSONModel();
						oModel1.setData({
							HierarchySet: flattenedData
						});
						oTable.setModel(oModel1);
						oTable.bindRows({
							path: "/HierarchySet",
							parameters: {
								arrayNames: ["children"]
							}
						});
						/*oTable.bindRows({
        					path: "/HierarchySet",
            				parameters : {
                				countMode: "Inline",
                				operationMode: "Client",
                				treeAnnotationProperties : {
                    				hierarchyLevelFor : "Hier_Level",
                    				hierarchyNodeFor : "NodeID",
                    				hierarchyParentNodeFor : "ParentID",
                    				hierarchyDrillStateFor : "DrillState"
                				}
            				}
        				});*/
					}
				},
				error: function (oData) {
					MessageToast.show("Invalid BOPF name", {
						duration: 2000,
						width: "15rem"
					});
				}
			});

			oTable.getBinding("rows").refresh();
		},

		findParent: function (acc, curr) {
			if (!acc.children) return undefined;
			for (var i = 0; i < acc.children.length; i++) {
				if (acc.children[i].NodeID === curr.ParentID) {
					return acc.children[i];
				} else {
					this.findParent(acc.children[i], curr);
				}
			}
		},
		flatten: function (obj) {
			var res = {};

			for (var i = 0; i < obj.length; i++) {
				var curr = obj[i];
				if (curr.ParentID === 0) {
					res = {
						NodeID: curr.NodeID,
						Name: curr.Name,
						Description: curr.Description,
						Table_name: curr.Table_name
					};
				} else if (curr.ParentID === 1) {
					if (!res.children) {
						res.children = [];
					}
					res.children.push({
						NodeID: curr.NodeID,
						Name: curr.Name,
						Description: curr.Description,
						Table_name: curr.Table_name
					});
				} else {
					var parent = this.findParent(res, curr);
					if (parent) {
						if (!parent.children) {
							parent.children = [];
						}
						parent.children.push({
							NodeID: curr.NodeID,
							Name: curr.Name,
							Description: curr.Description,
							Table_name: curr.Table_name
						});
					}
				}
			}
			return {
				children: res
			};
		},
		onHandlePress: function (oEvent) {
			var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
			var par = oEvent.getSource().getText();
			par = par.replaceAll("/", "!");
			oRouter.navTo("TableDetails", {
				parameter: par
			});
		}
	});
});