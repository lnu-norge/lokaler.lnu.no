# frozen_string_literal: true

# This can be safely removed once this issue is closed and merged into 10+ of the gem:
# https://github.com/rgeo/activerecord-postgis-adapter/issues/402

module ActiveRecord
  module ConnectionAdapters
    module PostGIS
      module Quoting
        def type_cast(value)
          case value
          when RGeo::Feature::Instance
            value.to_s
          else
            super
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::PostGISAdapter.include(ActiveRecord::ConnectionAdapters::PostGIS::Quoting)
end
