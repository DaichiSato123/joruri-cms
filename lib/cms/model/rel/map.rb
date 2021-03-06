# encoding: utf-8
module Cms::Model::Rel::Map
  extend ActiveSupport::Concern

  included do
    has_many :maps, primary_key: 'unid', foreign_key: 'unid',
                    class_name: 'Cms::Map', dependent: :destroy

    after_save :save_maps
  end

  def in_maps
    unless val = @in_maps
      val = []
      maps.each { |map| val << map.in_attributes }
      @in_maps = val
    end
    @in_maps
  end

  def in_maps=(values)
    @maps = values
    @in_maps = @maps
  end

  def default_map_position
    '34.074598,134.551411' # tokushima
  end

  def find_map_by_name(name)
    return nil if maps.empty?
    maps.each do |map|
      return map if map.name == name
    end
    nil
  end

  def save_maps
    return true  unless @maps
    return false unless unid
    return false if @_sent_save_maps
    @_sent_save_maps = true

    @maps.each do |_key, in_map|
      name = in_map[:name] || '1'
      map  = find_map_by_name(name) || Cms::Map.new(unid: unid, name: name)
      map.title       = in_map[:title]
      map.map_lat     = in_map[:map_lat]
      map.map_lng     = in_map[:map_lng]
      map.map_zoom    = in_map[:map_zoom]
      next unless map.save

      if in_map[:markers]
        markers = map.markers
        saved   = 0
        in_map[:markers].each do |_key, in_marker|
          marker = markers[saved] || Cms::MapMarker.new(map_id: map.id)
          marker.sort_no = saved
          marker.name = in_marker[:name]
          marker.lat  = in_marker[:lat]
          marker.lng  = in_marker[:lng]
          saved += 1 if !marker.changed? || marker.save
        end

        del_markers = markers.slice(saved, markers.size)
        del_markers.each do |m|
          m.destroy if map.new_marker_format?
        end unless del_markers.blank?
      end

      map.convert_to_new_marker_format
    end

    # maps(true)
    true
  end
end
