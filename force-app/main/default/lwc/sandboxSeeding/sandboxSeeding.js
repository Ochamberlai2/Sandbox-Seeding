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
    this.fields = { data, error };
    console.log(JSON.parse(JSON.stringify(this.fields?.data)));
  }
  fields;

  handleObjectSelect(event) {
    this.selectedObject = event.target.value;
  }
}
