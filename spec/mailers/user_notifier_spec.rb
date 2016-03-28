require "rails_helper"

RSpec.describe UserNotifier, type: :mailer do
  describe 'send_update_email' do
    let(:user) { mock_model User, name: 'John', email: 'john@email.com', all_following: [User.new] }
    let(:article) {mock_model Article, title: 'John Smith', content: 'some content', state_id: 33}
    let(:mail) { UserNotifier.send_update_email(user,article) }

    it 'renders the subject' do
      expect(mail.subject).to eql('A new post has been added to EBWiki')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['EndBiasWiki@gmail.com'])
    end

    it 'includes @title' do
      expect(mail.body.encoded).to match(article.title)
    end
  end

  describe 'welcome_email' do
    let(:user) { mock_model User, name: 'John', email: 'john@email.com', all_following: [Article.new]}
    let(:mail) { UserNotifier.welcome_email(user) }

    it 'renders the subject' do
      expect(mail.subject).to eql('Welcome to EndBiasWiki')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['EndBiasWiki@gmail.com'])
    end

    it 'includes @user.name' do
      expect(mail.body.encoded).to match(user.name)
    end
  end

  describe 'followers_email' do
    let(:user) { mock_model User, name: 'John', email: 'john@email.com', all_following: [Article.new]}
    let(:user_two) { mock_model User, name: 'Brown', email: 'brown@email.com', all_following: [Article.new]}
    let(:article) {mock_model Article, title: 'John Smith', content: 'some content', state_id: 33}
    users = [:user, :user_two]
    let(:mail) { UserNotifier.send_followers_email(users, article) }

    it 'renders the subject' do
      expect(mail.subject).to eql('The John Smith case has been updated on EBWiki.')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(['EndBiasWiki@gmail.com'])
    end
  end
end
