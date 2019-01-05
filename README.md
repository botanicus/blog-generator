# About

[![Build Status](https://travis-ci.org/botanicus/blog-generator.svg?branch=master)](https://travis-ci.org/botanicus/blog-generator)

Blog-generator is a static site generator that generates only JSON files that can
be consumed from a framework such as React.js. Think Nanoc but for fake APIs.

# Usage

```
gem install blog-generator
gem install redcarpet # If you are going to use markdown.
mkdir myblog.com
cd myblog.com
blog-generator.rb draft hello-world # Optionally hello-world.md, otherwise defaults to .html.
blog-generator.rb publish hello-world
blog-generator.rb generate api.myblog.com
```

## Development

To include drafts in your output JSON:

```
blog-generator.rb draft my-draft
blog-generator.rb generate api.myblog.com --include-drafts
```

## Updating posts

If you updated either excerpt or body of a post, the digest will no longer match
and you will get a warning upon running generate. You can either run `blog-generator.rb update my-post` to add `updated_at` timestamp and update the digest or `blog-generator.rb ignore_update my-post` to dismiss the update and only regenerate the digest.

# Post structure

```html
title: 'Hello world!'
tags: ['Hello world', 'Test']
---

<p id="excerpt">
  Excerpt
</p>

<h1>Hello world!</h1>
<p>
  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Soluta quibusdam necessitatibus tempore ullam incidunt amet omnis, veritatis dicta quisquam accusamus at provident vel facere corporis sed fugiat cumque. Consequuntur, necessitatibus!
</p>

<!-- This assumes assets/hello-world/hello-kitty.png -->
<img src="/assets/hello-world/hello-kitty.png" />
<caption>Hello kitty!</caption>
```

## Assumptions

- Metadata `title` and optionally `tags`.
- Metadata `draft: true` will exclude the post.
- Any other metadata can be added and will be accessible in the resulting JSON.
- Body has `#excerpt`.
- Format `posts/:published_at-:slug.:format`.

# Routes generated

- `slug` and `published_at` added to metadata.
- `/metadata.json`
- `/posts.json`
- `/posts/:slug.json`
- `/tags.json`
- `/tags/:slug.json`
