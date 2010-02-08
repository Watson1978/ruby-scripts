require 'rubygems'
require 'osx/cocoa'
require 'active_support'

# Copyright (c) Marcus Crafter <crafterm@redartisan.com>
#
class Processor

  def initialize(original)
    @original = original
  end

  def resize(width, height)
    create_core_image_context(width, height)

    scale_x, scale_y = scale(width, height)

    @original.affine_clamp :inputTransform => OSX::NSAffineTransform.transform do |clamped|
      clamped.lanczos_scale_transform :inputScale => scale_x > scale_y ? scale_x : scale_y, :inputAspectRatio => scale_x / scale_y do |scaled|
        scaled.crop :inputRectangle => vector(0, 0, width, height) do |cropped|
          @target = cropped
        end
      end
    end
  end

  def fit(size)
    original_size = @original.extent.size
    scale = size.to_f / (original_size.width > original_size.height ? original_size.width : original_size.height)
    resize (original_size.width * scale).to_i, (original_size.height * scale).to_i
  end

  def render(&block)
    raise "unprocessed image: #{@original}" unless @target
    block.call @target
  end

  private

    def create_core_image_context(width, height)
        output = OSX::NSBitmapImageRep.alloc.initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel(nil, width, height, 8, 4, true, false, OSX::NSDeviceRGBColorSpace, 0, 0)
        context = OSX::NSGraphicsContext.graphicsContextWithBitmapImageRep(output)
        OSX::NSGraphicsContext.setCurrentContext(context)
        @ci_context = context.CIContext
    end

    def vector(x, y, w, h)
      OSX::CIVector.vectorWithX_Y_Z_W(x, y, w, h)
    end

    def scale(width, height)
      original_size = @original.extent.size
      return width.to_f / original_size.width.to_f, height.to_f / original_size.height.to_f
    end

end

module OSX
  class CIImage
    include OCObjWrapper

    def method_missing_with_filter_processing(sym, *args, &block)
      f = OSX::CIFilter.filterWithName("CI#{sym.to_s.camelize}")
      return method_missing_without_filter_processing(sym, *args, &block) unless f

      f.setDefaults if f.respond_to? :setDefaults
      f.setValue_forKey(self, 'inputImage')
      options = args.last.is_a?(Hash) ? args.last : {}
      options.each { |k, v| f.setValue_forKey(v, k.to_s) }

      block.call f.valueForKey('outputImage')
    end

    alias_method_chain :method_missing, :filter_processing

    def save(target, format, properties = nil)
      bitmapRep = OSX::NSBitmapImageRep.alloc.initWithCIImage(self)
      blob = bitmapRep.representationUsingType_properties(format, properties)
      blob.writeToFile_atomically(target, false)
    end

    def self.from(filepath)
      OSX::CIImage.imageWithContentsOfURL(OSX::NSURL.fileURLWithPath(filepath))
    end
  end
end