require 'spec_helper'

class TrashableUser < ActiveRecord::Base
  self.table_name = 'users'
  trashable
end

class TrashableUserWithTrashedAtColumn < ActiveRecord::Base
  self.table_name = 'users'
  trashable column: :trashed_at
end

class TrashableNote < ActiveRecord::Base
  self.table_name = 'notes'
  trashable
  validates :body, presence: true
end

class TrashableUserWithNote < ActiveRecord::Base
  self.table_name = 'users'
  has_many :notes, class_name: 'TrashableNoteForUser', foreign_key: 'user_id'
  trashable also_trash: [:notes]
end

class TrashableNoteForUser < TrashableNote
  belongs_to :user, class_name: 'TrashableUserWithNote'
end

describe 'Options' do
  describe 'column' do
    let!(:user) { TrashableUserWithTrashedAtColumn.create }

    it 'functions properly' do
      expect(TrashableUserWithTrashedAtColumn.count).to eq 1
      user.trash!
      expect(TrashableUserWithTrashedAtColumn.count).to eq 0
    end
  end

  describe 'also_trash' do
    let!(:user) { TrashableUserWithNote.create }
    let!(:note) { TrashableNoteForUser.create(body: 'foo', user: user) }

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
  let!(:user) { TrashableUser.create }

  it 'excludes trashed objects' do
    expect(TrashableUser.count).to eq 1
    user.update deleted_at: Time.now
    expect(TrashableUser.count).to eq 0
  end

  it 'can be overridden' do
    expect(TrashableUser.count).to eq 1
    user.update deleted_at: Time.now
    expect(TrashableUser.with_deleted.count).to eq 1
  end
end

describe '#trashed?' do
  let!(:user) { TrashableUser.create }
  subject { user }

  it { should_not be_trashed }

  context 'when trashed' do
    before { user.update deleted_at: Time.now }
    it { should be_trashed }
  end
end

describe '#trash!' do
  let!(:user) { TrashableUser.create }

  it 'functions properly' do
    expect(user.deleted_at).to be_blank
    user.trash!
    expect(user.deleted_at).to be_present
    expect(user.reload.deleted_at).to be_present
  end

  context 'with callbacks' do
    before do
      TrashableUser.before_trash :do_before_trash
      TrashableUser.after_trash :do_after_trash
      TrashableUser.around_trash :do_around_trash
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
  let!(:user) { TrashableUser.create(deleted_at: Time.now) }

  it 'functions properly' do
    expect(user.deleted_at).to be_present
    user.recover!
    expect(user.deleted_at).to be_blank
    expect(user.reload.deleted_at).to be_blank
  end

  context 'with callbacks' do
    before do
      TrashableUser.before_recover :do_before_recover
      TrashableUser.after_recover :do_after_recover
      TrashableUser.around_recover :do_around_recover
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
