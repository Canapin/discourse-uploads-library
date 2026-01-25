import Component from "@glimmer/component";
import dModal from "discourse/components/d-modal";
import dIcon from "discourse-common/helpers/d-icon";
import { i18n } from "discourse-i18n";

<template>
  <dModal
    @title={{i18n "js.uploads_browser.usage_modal_title"}}
    @closeModal={{@closeModal}}
    class="upload-usage-modal"
  >
    <:body>
      <ul class="upload-usage-list">
        {{#each @model.posts as |post|}}
          <li>
            {{#if post.is_pm}}
              {{dIcon "envelope" title=(i18n "js.uploads_browser.is_pm")}}
            {{else}}
              {{dIcon "comment" title=(i18n "js.uploads_browser.is_post")}}
            {{/if}}
            <a href={{post.url}} target="_blank" rel="noopener noreferrer">
              {{post.topic_title}}
              (Post #{{post.post_number}})
            </a>
          </li>
        {{else}}
          <p>{{i18n "js.uploads_browser.no_posts_found"}}</p>
        {{/each}}
      </ul>
    </:body>
  </dModal>
</template>
