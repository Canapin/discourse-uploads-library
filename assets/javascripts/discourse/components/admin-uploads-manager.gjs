import Component from "@glimmer/component";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DatePicker from "discourse/components/date-picker";
import dIcon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import UserChooser from "select-kit/components/email-group-user-chooser";
import UploadUsageModal from "discourse/plugins/discourse-uploads-library/discourse/components/modal/upload-usage";

export default class AdminUploadsManager extends Component {
  @service modal;

  @action
  showUsage(upload, event) {
    event.preventDefault();
    this.modal.show(UploadUsageModal, {
      model: { posts: upload.posts || [] },
    });
  }

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
    queueMicrotask(() => {
      if (!this.isDestroyed && !this.isDestroying) {
        this.checkNeedsMoreContent();
      }
    });
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
    if (this.isDestroyed || this.isDestroying) {
      return;
    }

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
      class="admin-uploads-library-container"
      {{didInsert this.setupInfiniteScroll}}
      {{willDestroy this.teardownInfiniteScroll}}
    >
      <div class="admin-controls">
        <div class="control-unit">
          <label>{{i18n "js.uploads_library.user_label"}}</label>
          <UserChooser
            @value={{@username}}
            @onChange={{this.updateUsername}}
            @options={{hash excludeCurrentUser=false allowEmails=true}}
          />
        </div>

        <div class="control-unit">
          <label>{{i18n "js.uploads_library.from_label"}}</label>
          <DatePicker @value={{@fromDate}} @onChange={{this.updateFromDate}} />
        </div>

        <div class="control-unit">
          <label>{{i18n "js.uploads_library.to_label"}}</label>
          <DatePicker @value={{@toDate}} @onChange={{this.updateToDate}} />
        </div>

        {{#if this.showClearButton}}
          <div class="control-unit">
            <label>&nbsp;</label>
            <DButton
              @action={{@onClear}}
              @label="js.uploads_library.clear_filters"
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
              href={{upload.url}}
              class="preview-link"
              {{on "click" (fn this.showUsage upload)}}
            >
              <span class="image-container">
                {{#if upload.is_image}}
                  <img
                    src={{upload.thumbnail_url}}
                    class="upload-thumb"
                    loading="lazy"
                    alt={{upload.name}}
                  />
                {{else}}
                  <span class="file-placeholder">
                    {{dIcon "file"}}
                    <span class="extension">{{upload.name}}</span>
                  </span>
                {{/if}}
              </span>
              <div class="file-name" title={{upload.name}}>{{upload.name}}</div>
            </a>
            {{#if upload.username}}
              <a class="upload-user" href="/u/{{upload.username}}">
                <span class="user-profile-link">
                  @{{upload.username}}
                </span>
              </a>
            {{/if}}
          </div>
        {{else}}
          {{#unless @loading}}
            <div class="no-results">
              {{i18n "js.uploads_library.no_results"}}
            </div>
          {{/unless}}
        {{/each}}
      </div>

      {{#if @loading}}
        <div class="loading-indicator">
          {{dIcon "spinner" class="fa-spin"}}
        </div>
      {{/if}}
    </div>
  </template>
}
