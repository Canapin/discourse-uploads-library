import Component from "@glimmer/component";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";
import { hash } from "@ember/helper";
import dButton from "discourse/components/d-button";
import datePicker from "discourse/components/date-picker";
import userChooser from "select-kit/components/email-group-user-chooser";
import dIcon from "discourse-common/helpers/d-icon";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";

export default class AdminUploadsManager extends Component {
  get showClearButton() {
    return this.args.username || this.args.fromDate || this.args.toDate;
  }

  @action
  updateUsername(val) {
    const selected = Array.isArray(val) ? val[0] : val;
    this.args.onChangeParams({ username: selected });
  }

  @action
  updateFromDate(val) {
    this.args.onChangeParams({ from_date: val });
  }

  @action
  updateToDate(val) {
    this.args.onChangeParams({ to_date: val });
  }

  @action
  setupInfiniteScroll() {
    window.addEventListener("scroll", this.onScroll);
    this.checkNeedsMoreContent();
  }

  @action
  teardownInfiniteScroll() {
    window.removeEventListener("scroll", this.onScroll);
  }

  @action
  onScroll() {
    const documentHeight = document.documentElement.scrollHeight;
    const windowHeight = window.innerHeight;
    const scrollTop = window.scrollY || document.documentElement.scrollTop;

    if (documentHeight - (scrollTop + windowHeight) < 300) {
      this.args.loadMore();
    }
  }

  @action
  checkNeedsMoreContent() {
    if (document.documentElement.scrollHeight <= window.innerHeight) {
      if (this.args.canLoadMore && !this.args.loading) {
        const promise = this.args.loadMore();
        if (promise && typeof promise.then === "function") {
          promise.then(() => {
            requestAnimationFrame(() => this.checkNeedsMoreContent());
          });
        }
      }
    }
  }

  <template>
    <div
      class="admin-uploads-container"
      {{didInsert this.setupInfiniteScroll}}
      {{willDestroy this.teardownInfiniteScroll}}
    >
      <div class="admin-controls">
        <div class="control-unit">
          <label>{{i18n "js.uploads_browser.user_label"}}</label>
          <userChooser
            @value={{@username}}
            @onChange={{this.updateUsername}}
            @options={{hash
              maximum=1
              filterPlaceholder="js.uploads_browser.user_search_placeholder"
            }}
          />
        </div>

        <div class="control-unit">
          <label>{{i18n "js.uploads_browser.from_label"}}</label>
          <datePicker @value={{@fromDate}} @onChange={{this.updateFromDate}} />
        </div>

        <div class="control-unit">
          <label>{{i18n "js.uploads_browser.to_label"}}</label>
          <datePicker @value={{@toDate}} @onChange={{this.updateToDate}} />
        </div>

        {{#if this.showClearButton}}
          <div class="control-unit">
            <dButton
              @action={{@onClear}}
              @label="js.uploads_browser.clear_filters"
              @icon="times"
              class="btn-default"
            />
          </div>
        {{/if}}
      </div>

      <div class="uploads-gallery">
        {{#each @uploads as |upload|}}
          <div class="upload-card">
            <a
              href={{upload.original_url}}
              target="_blank"
              class="preview-link"
              rel="noopener noreferrer"
            >
              {{#if upload.is_image}}
                <img src={{upload.url}} class="upload-thumb" loading="lazy" />
              {{else}}
                <div class="file-placeholder">
                  {{dIcon "file"}}
                  <span class="extension">{{upload.name}}</span>
                </div>
              {{/if}}
            </a>
            <div class="file-name" title={{upload.name}}>{{upload.name}}</div>
          </div>
        {{else}}
          {{#unless @loading}}
            <div class="no-results">
              {{i18n "js.uploads_browser.no_results"}}
            </div>
          {{/unless}}
        {{/each}}
      </div>

      {{#if @loading}}
        <div
          class="loading-indicator"
          style="text-align: center; padding: 20px;"
        >
          {{dIcon "spinner" class="fa-spin"}}
        </div>
      {{/if}}
    </div>
  </template>
}
