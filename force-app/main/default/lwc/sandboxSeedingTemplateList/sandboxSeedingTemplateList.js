import { LightningElement, wire } from "lwc";
import getSeedingTemplates from "@salesforce/apex/SandboxSeedingUtil.getSeedingTemplates";
export default class SandboxSeedingTemplateList extends LightningElement {
  seedingTemplates;
  @wire(getSeedingTemplates)
  getSeedingTemplates({ data, error }) {
    if (error) {
      console.error(error);
    } else if (data) {
      this.seedingTemplates = data;
    }
  }

  get hasRecords() {
    return (
      this.seedingTemplates !== undefined && this.seedingTemplates.length > 0
    );
  }
}
