# frozen_string_literal: true

require "spec_helper"

describe ArLazyPreload::Context do
  let(:user_without_posts) { User.create }
  let(:user_with_post) do
    user = User.create
    Post.create(user: user)
    user
  end

  subject! do
    ArLazyPreload::Context.new(
      model: User,
      records: [user_with_post, user_without_posts, nil],
      association_tree: [:comments]
    )
  end

  describe "#initialize" do
    it "assigns context for each record" do
      subject.records.each { |user| expect(user.lazy_preload_context).to eq(subject) }
    end

    it "compacts records" do
      expect(subject.records.size).to eq(2)
    end
  end

  describe "#preload_association" do
    it "does not preload association when it's not in the association_tree" do
      subject.preload_association(:posts)
      subject.records.each { |user| expect(user.posts.loaded?).to be_falsey }
    end

    it "preloads association when it's in the association_tree" do
      subject.preload_association(:comments)
      subject.records.each { |user| expect(user.comments.loaded?).to be_truthy }
    end

    it "creates child preloading context" do
      subject.preload_association(:comments)
      subject.records.map(&:comments).flatten.each do |comment|
        expect(comment.lazy_preload_context).not_to be_nil
      end
    end
  end
end
