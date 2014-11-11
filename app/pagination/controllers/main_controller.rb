module Pagination
  class MainController < Volt::ModelController

    def middle_window(cpage, total)
      side_size = ((window - 1) / 2).ceil

      start_pos = cpage - side_size
      end_pos = cpage + side_size

      if start_pos <= 0
        end_pos += (0 - start_pos) + 1
        start_pos = 1
      end

      if end_pos > total
        start_pos = [start_pos - (end_pos - total), 1].max
        end_pos = total
      end

      end_pos = [end_pos, 1].max

      return start_pos, end_pos
    end

    def page_numbers
      total = total_pages()
      cpage = current_page()

      start_pos, end_pos = middle_window(cpage, total)
      middle_window = (start_pos..end_pos).to_a

      if outer_window == 0
        pages = middle_window
      else
        side_size = ((outer_window - 1) / 2).ceil

        start_outer_pos = [1 + side_size, start_pos-1].min
        end_outer_pos = [total - side_size, end_pos + 1].max

        start_window = (1..start_outer_pos).to_a
        end_window = (end_outer_pos..total).to_a

        pages = start_window
        pages << nil unless start_outer_pos == (middle_window[0] - 1)
        pages += middle_window
        pages << nil unless end_outer_pos == middle_window[-1] + 1
        pages += end_window
      end

      return pages
    end

    def window
      attrs.window.or(5).to_i
    end

    def outer_window
      attrs.outer_window.or(1).to_i
    end

    def per_page
      attrs.per_page.or(10).to_i
    end

    def current_page
      (attrs.page || params._page).or(1).to_i
    end

    def total_pages
      (attrs.total.to_i / per_page.to_f).ceil
    end

    def last_page
      current_page == page_numbers.last
    end

    def first_page
      current_page == 1
    end

    def next_page
      return 2 unless current_page
      return nil if last_page
      current_page + 1
    end

    def previous_page
      return nil unless current_page
      return nil if first_page
      current_page - 1
    end

    def go_next_page
      set_page(next_page) if next_page
    end

    def go_previous_page
      set_page(previous_page) if previous_page
    end

    def set_page(page_number)
      return unless left_click?
      prevent_default
      page_number = page_number.to_i
      if attrs.respond_to?(:page=)
        attrs.page = page_number
      else
        params._page = page_number
      end
    end

    def left_click?
      `event.which` == 1
    end

    def prevent_default
      `event.preventDefault();`
      `event.stopPropagation();`
    end
  end
end
