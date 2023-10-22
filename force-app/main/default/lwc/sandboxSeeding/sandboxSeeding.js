import { LightningElement, wire } from "lwc";
import getObjects from "@salesforce/apex/SandboxSeedingUtil.getObjects";
import getFields from "@salesforce/apex/SandboxSeedingUtil.getFields";

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
  selectedObject = "Account";
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
    { label: "Name", value: "Name" },
    { label: "Date", value: "Date" },
    { label: "Number", value: "Number" },
    { label: "Text Value", value: "TextValue" },
    { label: "Specific Value", value: "SpecificValue" }
  ];

  handleObjectSelect(event) {
    this.selectedObject = event.target.value;
  }

  handleTypeSelect(event) {
    const field = this.fields.find(event.target.dataset.key);
    if (field) {
      field.type = event.target.dataset.key;
    }
  }
}
