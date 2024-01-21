import { LightningElement, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

import { publish, MessageContext } from "lightning/messageService";
import seedingTemplatePress from "@salesforce/messageChannel/seedingTemplatePress__c";

export default class SandboxSeedingTemplateListItem extends LightningElement {
  @api
  seedingTemplate;
  icon;

  @wire(MessageContext)
  messageContext;

  @wire(getObjectInfo, { objectApiName: "$seedingTemplate.Object_Api_Name__c" })
  getObjectInfo({ data, error }) {
    console.log(data, error);
    if (data) {
      this.icon = data.themeInfo.iconUrl;
      document.documentElement.style.setProperty(
        "--background-colour",
        "#" + data.themeInfo.color
      );
    }
  }

  handleCardSelect() {
    const payload = {
      label: this.seedingTemplate.Label,
      numRecords: this.seedingTemplate.Number_of_records__c,
      objectApiName: this.seedingTemplate.Object_Api_Name__c,
      objectShape: this.seedingTemplate.Object_Shape__c
    };

    publish(this.messageContext, seedingTemplatePress, payload);
  }

  get label() {
    return this.seedingTemplate.Label.replaceAll("_", " ");
  }

  get seedingTemplateFieldCount() {
    const shape = JSON.parse(this.seedingTemplate.Object_Shape__c);
    return shape.length;
  }
}
