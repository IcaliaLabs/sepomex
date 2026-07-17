# frozen_string_literal: true

# Paginatable
#
# Provides the `paginate` controller helper used by the API index actions.
#
# It reproduces the exact JSON contract the app historically served through the
# (now removed, unmaintained) `pager_api` gem: an Active Model Serializers
# `:json` collection plus a `meta.pagination` block, along with the `Link`,
# `X-Total-Pages` and `X-Total-Count` response headers — without depending on
# `pager_api` or any pagination backend (`pagy`/`kaminari`/`will_paginate`).
module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 15
  MAX_PER_PAGE = 200
  TOTAL_PAGES_HEADER = 'X-Total-Pages'
  TOTAL_COUNT_HEADER = 'X-Total-Count'

  # Renders `collection` (an ActiveRecord::Relation) as a paginated JSON
  # response. `per_page` mirrors the value the controllers compute from
  # `params[:per_page]`; it is coerced and bounded defensively here too.
  #
  #   paginate ZipCode.search(params), per_page: 50
  def paginate(collection, per_page: nil)
    per_page = bounded_per_page(per_page)
    total_objects = collection.count(:all)
    total_pages = [(total_objects.to_f / per_page).ceil, 1].max
    page = [params[:page].to_i, 1].max

    targets = page_targets(page: page, total_pages: total_pages)
    records = collection.limit(per_page).offset((page - 1) * per_page)

    set_pagination_headers(targets, total_pages: total_pages, total_objects: total_objects)

    render json: records, meta: {
      pagination: {
        per_page: per_page,
        total_pages: total_pages,
        total_objects: total_objects,
        links: pagination_links(targets)
      }
    }
  end

  private

  def bounded_per_page(per_page)
    per_page = per_page.to_i
    return DEFAULT_PER_PAGE if per_page < 1

    [per_page, MAX_PER_PAGE].min
  end

  # The page numbers each relation link points at, in the historical order:
  # first, last, then prev/next when they exist.
  def page_targets(page:, total_pages:)
    {}.tap do |targets|
      targets[:first] = 1
      targets[:last] = total_pages
      targets[:prev] = page - 1 if page > 1
      targets[:next] = page + 1 if page < total_pages
    end
  end

  # meta.pagination.links — path-only, preserving the current query string.
  def pagination_links(targets)
    targets.transform_values do |page_number|
      "#{request.path}?#{request.query_parameters.merge(page: page_number).to_param}"
    end
  end

  def set_pagination_headers(targets, total_pages:, total_objects:)
    clean_url = request.original_url.sub(/\?.*\z/, '')
    link_header = targets.map do |rel, page_number|
      query = request.query_parameters.merge(page: page_number).to_param
      %(<#{clean_url}?#{query}>; rel="#{rel}")
    end.join(', ')

    response.headers['Link'] = link_header if link_header.present?
    response.headers[TOTAL_PAGES_HEADER] = total_pages.to_s
    response.headers[TOTAL_COUNT_HEADER] = total_objects.to_s
  end
end
