import { LightningElement, wire } from "lwc";
import getObjects from "@salesforce/apex/SandboxSeedingUtil.getObjects";
import getFields from "@salesforce/apex/SandboxSeedingUtil.getFields";
import seedSandbox from "@salesforce/apex/SandboxSeedingUtil.seedSandbox";
import insertSeedingTemplate from "@salesforce/apex/CustomMetadataUtil.insertSeedingTemplate";

export default class SandboxSeeding extends LightningElement {
  @wire(getObjects)
  objectsWire({ data, error }) {
    this.objects = { data, error };
    if (this.objects.data !== undefined) {
      this.objectsOptions = [];
      const objectValues = Object.values(this.objects?.data);
      objectValues.sort();
      objectValues.forEach((obj) => {
        this.objectsOptions.push({
          label: obj,
          value: obj
        });
      });
    }
  }
  objects;
  objectsOptions;
  selectedObject;
  @wire(getFields, { selectedObject: "$selectedObject" })
  fieldsWire({ data, error }) {
    this.fields = [];
    if (data) {
      data.forEach((field) => {
        this.fields.push({
          key: field
        });
      });
    }
  }
  fields;
  typeOptions = [
    { label: "Company Name", value: "CompanyName" },
    { label: "First Name", value: "FirstName" },
    { label: "Last Name", value: "LastName" },
    { label: "Date", value: "Date" },
    { label: "Number", value: "Number" },
    { label: "Text Value", value: "TextValue" },
    { label: "Specific Value", value: "SpecificValue" }
  ];

  handleObjectSelect(event) {
    this.selectedObject = event.target.value;
  }

  handleTypeSelect(event) {
    const field = this.fields.find(
      (fieldObject) => event.target.dataset.key === fieldObject.key
    );
    if (field) {
      field.type = event.target.value;
    }
  }
  createObjectTemplate() {
    const populatedFields = this.fields.filter(
      (field) => field.type !== undefined
    );
    const stringifiedFields = JSON.stringify(populatedFields);

    insertSeedingTemplate({
      seedingTemplate: {
        Label: this.selectedObject,
        MasterLabel: this.selectedObject,
        Object_Shape__c: stringifiedFields,
        Object_Api_Name__c: this.selectedObject,
        Number_of_records__c: 1
      }
    });
  }
  seedSandbox() {
    try {
      seedSandbox();
    } catch (error) {
      console.error(error);
    }
  }
}
