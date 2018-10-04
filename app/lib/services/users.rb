module Services
  class Users
    def initialize(current_user, page)
      @current_user = current_user
      @page = page
    end

    def all
      users = search_present? ? get_all_indexed_users : get_all_users
      users.compact! if (users && users.is_a?(Array))
      users
    end

    private

    attr_reader :current_user, :page

    def search_present?
      current_user.search_criteria.present?
    end

    def get_all_users
      ::User.get_all.except_user(current_user).confirmed.page(page)
    end

    def get_all_indexed_users
      ::User.search(last_search, current_user).page(page).objects
    end

    def last_search
      current_user.search_criteria.last
    end
  end
end
