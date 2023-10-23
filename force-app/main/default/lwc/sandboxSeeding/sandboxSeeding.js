import { LightningElement, wire, track } from "lwc";
import getObjects from "@salesforce/apex/SandboxSeedingUtil.getObjects";
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

  @track
  fields;
  numberOfRecords;

  handleObjectSelect(event) {
    this.selectedObject = event.target.value;
  }
  handleTemplateNameChange(event) {
    this.templateName = event.target.value;
  }
  handleNumberRecordsChange(event) {
    this.numberOfRecords = event.target.value;
  }
  handleFieldChange(event) {
    this.fields = event.detail;
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
