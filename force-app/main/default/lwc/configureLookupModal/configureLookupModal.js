import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class ConfigureLookupModal extends LightningModal {
  @api selectedObject;
  @api relatedField;
  fields;
  handleOkay() {
    this.dispatchEvent(
      new CustomEvent("fieldchange", {
        detail: { fields: this.fields, relatedField: this.relatedField }
      })
    );
    this.close("okay");
  }

  handleFieldChange(event) {
    const fields = event.detail;
    const populatedFields = fields.filter((field) => field.type !== undefined);

    this.fields = populatedFields;
  }
}
