# frozen_string_literal: true

require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "auto-generates a slug from the title" do
    post = Post.create!(title: "How Much Does a Website Cost?", excerpt: "A guide.")
    assert_equal "how-much-does-a-website-cost", post.slug
  end

  test "ensures unique slugs" do
    Post.create!(title: "Same Title", excerpt: "One")
    second = Post.create!(title: "Same Title", excerpt: "Two")
    assert_equal "same-title-2", second.slug
  end

  test "computes reading minutes from the body" do
    post = Post.create!(title: "Reading Time", excerpt: "x", body: ("word " * 400))
    assert_equal 2, post.reading_minutes
  end

  test "live scope only returns published posts with a past published_at" do
    published = Post.create!(title: "Live", excerpt: "x", status: :published)
    draft     = Post.create!(title: "Draft", excerpt: "x", status: :draft)
    future    = Post.create!(title: "Future", excerpt: "x", status: :published,
                             published_at: 2.days.from_now)
    live = Post.live
    assert_includes live, published
    assert_not_includes live, draft
    assert_not_includes live, future
  end

  test "publishing sets published_at" do
    post = Post.create!(title: "Publish Me", excerpt: "x", status: :published)
    assert_not_nil post.published_at
  end

  test "to_param returns the slug" do
    post = Post.create!(title: "Param Post", excerpt: "x")
    assert_equal post.slug, post.to_param
  end
end
