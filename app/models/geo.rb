# frozen_string_literal: true

# RGeo is powerful, but verbose. This helper method makes it easier to use.
# If you need to get down to the metal, you can use the RGeo methods directly
# by calling Geo.factory, and unrecognized commands are automatically passed on
# to the factory.
# That means you can call Geo.point, Geo.line_string, Geo.polygon, etc.
class Geo
  SRID = 4326 # Standard for GPS coordinates

  def self.factory
    @factory ||= RGeo::Geographic.spherical_factory(srid: SRID)
    # Using spherical_factory might be overkill, but it's the most accurate.
    # If we need more speed we can change it to a 2D cartesian factory and repopulate + migrate
  end

  def self.polygon(points)
    line = line_string(points)
    factory.polygon(line)
  end

  def self.to_wkt(feature)
    "srid=#{SRID};#{feature}"
  end

  # Send anything to the factory that we haven't defined or changed:
  def self.method_missing(method, *, &)
    if factory.respond_to?(method)
      factory.public_send(method, *, &)
    else
      super
    end
  end

  def self.respond_to_missing?(method, include_private = false)
    factory.respond_to?(method) || super
  end
end
