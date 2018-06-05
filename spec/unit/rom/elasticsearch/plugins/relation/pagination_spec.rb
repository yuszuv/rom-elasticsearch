require 'rom/elasticsearch/plugins/relation/pagination'

RSpec.describe 'Plugin / Pagination' do
  subject(:relation){ relations[:users] }

  include_context 'users'

  before do
    9.times do |n|
      relation.command(:create).(id: 1, name: "User #{n}")
    end

    conf.relation(:users) do
      use :pagination

      per_page 4
    end

    relation.refresh
  end

  describe '#page' do
    it 'allow to call with stringify number' do
      expect {
        container.relations[:users].page('5')
      }.to_not raise_error
    end

    it 'preserves existing modifiers' do
      expect(
        container.relations[:users].send(:where, name: 'User 2').page(1).to_a.size
      ).to be(1)
    end
  end

  describe '#per_page' do
    it 'allow to call with stringify number' do
      expect {
        container.relations[:users].per_page('5')
      }.to_not raise_error
    end

    it 'returns paginated relation with provided limit' do
      users = container.relations[:users].page(2).per_page(5)

      expect(users.dataset.opts[:offset]).to eql(5)
      expect(users.dataset.opts[:limit]).to eql(5)

      expect(users.pager.current_page).to eql(2)

      expect(users.pager.total).to be(9)
      expect(users.pager.total_pages).to be(2)

      expect(users.pager.next_page).to be(nil)
      expect(users.pager.prev_page).to be(1)
      expect(users.pager.limit_value).to eql(5)
    end
  end

  describe '#total_pages' do
    it 'returns a single page when elements are a perfect fit' do
      users = container.relations[:users].page(1).per_page(3)
      expect(users.pager.total_pages).to eql(3)
    end

    it 'returns the exact number of pages to accommodate all elements' do
      users = container.relations[:users].per_page(9)
      expect(users.pager.total_pages).to eql(1)
    end
  end

  describe '#pager' do
    it 'returns a pager with pagination meta-info' do
      users = container.relations[:users].page(1)

      expect(users.pager.total).to be(9)
      expect(users.pager.total_pages).to be(3)

      expect(users.pager.current_page).to be(1)
      expect(users.pager.next_page).to be(2)
      expect(users.pager.prev_page).to be(nil)

      users = container.relations[:users].page(2)

      expect(users.pager.current_page).to be(2)
      expect(users.pager.next_page).to be(3)
      expect(users.pager.prev_page).to be(1)

      users = container.relations[:users].page(3)

      expect(users.pager.next_page).to be(nil)
      expect(users.pager.prev_page).to be(2)
    end
  end
end
