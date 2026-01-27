import DModal from "discourse/components/d-modal";
import dIcon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

<template>
  <DModal
    @title={{i18n "js.uploads_library.usage_modal_title"}}
    @closeModal={{@closeModal}}
    class="upload-usage-modal"
  >
    <:body>
      <ul class="upload-usage-list">
        {{#each @model.posts as |post|}}
          <li>
            <a
              href={{post.url}}
              target="_blank"
              rel="noopener noreferrer"
              title={{if
                post.is_pm
                (i18n "uploads_library.is_pm")
                (i18n "uploads_library.is_post")
              }}
            >
              {{#if post.is_pm}}
                {{dIcon "envelope"}}
              {{else}}
                {{dIcon "comment"}}
              {{/if}}
              {{post.topic_title}}
              (Post #{{post.post_number}})
            </a>
          </li>
        {{else}}
          <p>{{i18n "js.uploads_library.no_posts_found"}}</p>
        {{/each}}
      </ul>
    </:body>
  </DModal>
</template>
