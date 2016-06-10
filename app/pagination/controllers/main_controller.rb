module Pagination
  class MainController < Volt::ModelController

    def page_numbers(i=nil)
      total_pages.then do |total|
        if i == 0
          start_pos, end_pos = middle_window(controller._pages[2] - 3, total)
          middle_window = (start_pos..end_pos).to_a
        elsif i == 1
          start_pos, end_pos = middle_window(controller._pages[2] + window + 2, total)
          middle_window = (start_pos..end_pos).to_a
        else
          start_pos, end_pos = middle_window(current_page, total)
          middle_window = (start_pos..end_pos).to_a
        end

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
          pages << 0 unless end_outer_pos == middle_window[-1] + 1
          pages += end_window
        end
        controller._pages = pages
      end
    end

    def expand_pages x
      page_numbers(x).then do |pages|
        controller._pages = pages
      end
    end

    def certain_page
      controller._pages
    end

    def window
      (attrs.window || 5).to_i
    end

    def outer_window
      (attrs.outer_window || 1).to_i
    end

    def middle_window cpage, total
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

      [start_pos, end_pos]
    end

    def per_page
      (attrs.per_page || 10).to_i
    end

    def current_page
      (params.send(:"_#{page_param_name}") || 1).to_i
    end

    # Assumes a promise and returns a promise
    def total_pages
      attrs.total.then do |total|
        (total.to_i / per_page.to_f).ceil
      end
    end

    def last_page
      current_page == page_numbers.last
    end

    def first_page
      current_page == 1
    end

    def goto_next_page
      Promise.when(current_page, total_pages).then do |current_page, total_pages|
        page = [(current_page + 1), total_pages].min
        set_page(page)
      end
    end

    def goto_previous_page
      current_page.then do |current_page|
        page = [(current_page - 1), 1].max
        set_page(page)
      end
    end

    def page_param_name
      attrs.page_param_name || :page
    end

    def set_page page_number
      page_number.then do
        params.send(:"_#{page_param_name}=", page_number.to_i)
      end
    end
  end
end
