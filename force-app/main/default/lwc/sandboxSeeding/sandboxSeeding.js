import { LightningElement, wire, track } from "lwc";
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
  @track
  fields;
  templateName;
  numberOfRecords;
  typeOptions = [
    { label: "Company Name", value: "CompanyName" },
    { label: "First Name", value: "FirstName" },
    { label: "Last Name", value: "LastName" },
    { label: "Date", value: "Date" },
    { label: "Number", value: "Number" },
    { label: "Text Value", value: "TextValue" },
    { label: "Specific Value", value: "SpecificValue" },
    { label: "--None--", value: "" }
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
      field.isSpecific = event.target.value === "SpecificValue";
    }
  }
  handleTemplateNameChange(event) {
    this.templateName = event.target.value;
  }
  handleNumberRecordsChange(event) {
    this.numberOfRecords = event.target.value;
  }
  handleSpecificValueChange(event) {
    const field = this.fields.find(
      (fieldObject) => event.target.dataset.key === fieldObject.key
    );
    if (field) {
      field.specificValue = event.target.value;
    }
  }
  createObjectTemplate() {
    const populatedFields = this.fields.filter(
      (field) => field.type !== undefined
    );
    const stringifiedFields = JSON.stringify(populatedFields);

    insertSeedingTemplate({
      seedingTemplate: {
        Label: this.templateName,
        MasterLabel: this.templateName,
        Object_Shape__c: stringifiedFields,
        Object_Api_Name__c: this.selectedObject,
        Number_of_records__c: this.numberOfRecords
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
