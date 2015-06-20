# About

Few years back we used to use all the fancy static site generators for building a blog, so the blog could have layouts, tags, pagination and other features. With the arrival of frontend frameworks such as AngularJS, this is no longer necessary.

We can generate a static JSON API and let AngularJS handle the rest.

# Usage

gem install blog-generator
gem install redcarpet # If you are going to use markdown.
mkdir botanicus.me
cd botanicus.me
mkdir posts
blog-generator.rb posts api

# Post structure

```html
title: 'Hello world!'
tags: ['Hello world', 'Test']
---

<div id="excerpt">
  Excerpt
</div>


<h1>Hello world!</h1>
<p>
  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Soluta quibusdam necessitatibus tempore ullam incidunt amet omnis, veritatis dicta quisquam accusamus at provident vel facere corporis sed fugiat cumque. Consequuntur, necessitatibus!
</p>
```

## Assumptions

- Metadata `title` and optionally `tags`.
- Metadata `draft: true` will exclude the post.
- Any other metadata can be added and will be accessible in the resulting JSON.
- Body has `#excerpt`.
- Format `posts/:published_on-:key.:format`.

# Routes generated

- `key` and `published_on` added to metadata.
- `/metadata.json`
- `/posts.json`
- `/posts/:key.json`
- `/tags.json`
- `/tags/:key.json`

# Feeds

```html
<!-- Global feed. -->
<link href="{{blog.feed_url}}" type="application/atom+xml" rel="alternate" title="{{blog.title}}" />

<!-- Per-tag feeds. -->
<link href="{{tag.feed_url}}" type="application/atom+xml" rel="alternate" title="{{tag.title}}" />
```

# Status

It works, but it needs polishing.

# TODO

- Generate assets by parsing the document, no explicit spec.
- GH markdown including source code support.
