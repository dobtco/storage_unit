require 'spec_helper'

class User < ActiveRecord::Base
  self.table_name = 'users'
  has_storage_unit
end

class UserWithTrashedAtColumn < ActiveRecord::Base
  self.table_name = 'users'
  has_storage_unit column: :trashed_at
end

class TrashableNote < ActiveRecord::Base
  self.table_name = 'notes'
  has_storage_unit
  validates :body, presence: true
end

class UserWithNote < ActiveRecord::Base
  self.table_name = 'users'
  has_many :notes, class_name: 'NoteForUser', foreign_key: 'user_id'
  has_storage_unit cascade: [:notes]
end

class NoteForUser < TrashableNote
  belongs_to :user, class_name: 'UserWithNote'
end

describe 'Options' do
  describe 'column' do
    let!(:user) { UserWithTrashedAtColumn.create }

    it 'functions properly' do
      expect(UserWithTrashedAtColumn.count).to eq 1
      user.trash!
      expect(UserWithTrashedAtColumn.count).to eq 0
    end
  end

  describe 'cascade' do
    let!(:user) { UserWithNote.create }
    let!(:note) { NoteForUser.create(body: 'foo', user: user) }

    describe '#trash!' do
      it 'trashes associated records' do
        expect(user.deleted_at).to be_blank
        expect(note.deleted_at).to be_blank
        user.trash!
        expect(user.reload.deleted_at).to be_present
        expect(note.reload.deleted_at).to be_present
      end
    end

    describe '#recover!' do
      before do
        user.update_attributes deleted_at: Time.now
        note.update_attributes deleted_at: Time.now
      end

      it 'recovers associated records' do
        expect(user.deleted_at).to be_present
        expect(note.deleted_at).to be_present
        user.recover!
        expect(user.reload.deleted_at).to be_blank
        expect(note.reload.deleted_at).to be_blank
      end
    end
  end
end

describe 'Default scope' do
  let!(:user) { User.create }

  it 'excludes trashed objects' do
    expect(User.count).to eq 1
    user.update deleted_at: Time.now
    expect(User.count).to eq 0
  end

  it 'can be overridden' do
    expect(User.count).to eq 1
    user.update deleted_at: Time.now
    expect(User.with_deleted.count).to eq 1
  end
end

describe '#trashed?' do
  let!(:user) { User.create }
  subject { user }

  it { should_not be_trashed }

  context 'when trashed' do
    before { user.update deleted_at: Time.now }
    it { should be_trashed }
  end
end

describe '#trash!' do
  let!(:user) { User.create }

  it 'functions properly' do
    expect(user.deleted_at).to be_blank
    user.trash!
    expect(user.deleted_at).to be_present
    expect(user.reload.deleted_at).to be_present
  end

  context 'with callbacks' do
    before do
      User.before_trash :do_before_trash
      User.after_trash :do_after_trash
      User.around_trash :do_around_trash
    end

    it 'calls them' do
      expect(user).to receive(:do_before_trash)
      expect(user).to receive(:do_after_trash)
      expect(user).to receive(:do_around_trash)
      user.trash!
    end
  end
end

describe '#recover!' do
  let!(:user) { User.create(deleted_at: Time.now) }

  it 'functions properly' do
    expect(user.deleted_at).to be_present
    user.recover!
    expect(user.deleted_at).to be_blank
    expect(user.reload.deleted_at).to be_blank
  end

  context 'with callbacks' do
    before do
      User.before_recover :do_before_recover
      User.after_recover :do_after_recover
      User.around_recover :do_around_recover
    end

    it 'calls them' do
      expect(user).to receive(:do_before_recover)
      expect(user).to receive(:do_after_recover)
      expect(user).to receive(:do_around_recover)
      user.recover!
    end
  end

  context 'when invalid' do
    let!(:note) do
      note = TrashableNote.new(deleted_at: Time.now)
      note.save(validate: false)
      note
    end

    it 'does not care' do
      expect {
        note.recover!
      }.to_not raise_error

      expect(note).to_not be_valid
    end
  end
end
