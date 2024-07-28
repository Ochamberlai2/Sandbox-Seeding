import { LightningElement, api, wire, track } from "lwc";
import Toast from "lightning/toast";

import getObjectNameFromLookup from "@salesforce/apex/SandboxSeedingUtil.getObjectNameFromLookup";
import getFields from "@salesforce/apex/SandboxSeedingUtil.getFields";
import configureLookupModal from "c/configureLookupModal";

export default class FieldList extends LightningElement {
  @api
  selectedObject;
  @api
  defaultFields;
  @track
  fields;
  templateName;

  typeOptions = [
    { label: "Company Name", value: "CompanyName" },
    { label: "First Name", value: "FirstName" },
    { label: "Last Name", value: "LastName" },
    { label: "Date", value: "Date" },
    { label: "Number", value: "Number" },
    { label: "Text Value", value: "TextValue" },
    { label: "Specific Value", value: "SpecificValue" },
    { label: "Lookup", value: "Lookup" },
    { label: "--None--", value: "" }
  ];

  @wire(getFields, { selectedObject: "$selectedObject" })
  fieldsWire({ data, error }) {
    this.fields = [];
    if (data) {
      data.forEach((field) => {
        const defaultField = {};
        if (this.defaultFields) {
          this.defaultFields.find((item) => item.key === field);
        }
        this.fields.push({
          key: field,
          ...defaultField
        });
      });
    }
    if (error) {
      console.log(error);
    }
  }

  async handleTypeSelect(event) {
    const field = this.fields.find(
      (fieldObject) => event.target.dataset.key === fieldObject.key
    );
    if (field) {
      field.type = event.target.value;
      field.isSpecific = event.target.value === "SpecificValue";

      if (event.target.value === "Lookup") {
        try {
          field.lookupObjectName = await getObjectNameFromLookup({
            objectName: this.selectedObject,
            fieldName: field.key
          });
          field.hasObjectName = field.lookupObjectName !== undefined;
        } catch (error) {
          Toast.show(
            {
              label: "Error!",
              message: "That field is not a lookup!",
              mode: "sticky",
              variant: "error"
            },
            this
          );
          field.type = "";
        }
      }
      this.communicateFieldChange();
    }
  }

  async handleConfigureLookupModalClick(event) {
    const { key } = event.target.dataset;
    const field = this.fields.find((item) => item.key === key);
    if (field) {
      await configureLookupModal.open({
        size: "large",
        selectedObject: field.lookupObjectName,
        relatedField: key,
        onfieldchange: (e) => this.handleFieldChange(e)
      });
      //comment
    }
  }
  handleFieldChange(event) {
    const { relatedField, fields } = event.detail;
    const field = this.fields.find((item) => item.key === relatedField);
    if (field) {
      field.lookupValue = fields;
      this.communicateFieldChange();
    }
  }
  handleSpecificValueChange(event) {
    const field = this.fields.find(
      (fieldObject) => event.target.dataset.key === fieldObject.key
    );
    if (field) {
      field.specificValue = event.target.value;
      this.communicateFieldChange();
    }
  }

  get hasFields() {
    return this.fields.length > 0;
  }

  communicateFieldChange() {
    this.dispatchEvent(new CustomEvent("fieldchange", { detail: this.fields }));
  }
}
