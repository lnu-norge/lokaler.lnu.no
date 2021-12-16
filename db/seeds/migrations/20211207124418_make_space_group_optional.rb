# frozen_string_literal: true

# Remove any empty SpaceGroups set by mistake earlier:
SpaceGroup.where(title: "").destroy_all
