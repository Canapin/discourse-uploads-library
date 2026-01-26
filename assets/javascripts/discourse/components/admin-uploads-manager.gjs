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

  @action
  stopPropagation(event) {
    event.stopPropagation();
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
            @options={{hash
              maximum=1
              filterPlaceholder="js.uploads_library.user_search_placeholder"
            }}
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
          <div class="upload-card" {{on "click" (fn this.showUsage upload)}}>
            <a href={{upload.original_url}} class="preview-link">
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
            {{#if upload.username}}
              <div class="upload-user">
                <a
                  href="/u/{{upload.username}}"
                  class="user-profile-link"
                  {{on "click" this.stopPropagation}}
                >
                  @{{upload.username}}
                </a>
              </div>
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
