# frozen_string_literal: true

# Search-helper table populated by ZipCode.build_indexes. Holds the
# accent-/case-normalized city, state, settlement and municipality strings the
# ZipCode search scopes match against with LIKE.
class FtsZipCode < ApplicationRecord
end
