#!/usr/local/bin/macruby
# -*- coding: utf-8 -*-
framework "JavaScriptCore"

module JSC
  module_function

  def eval(program)
    kJSPropertyAttributeNone = 0 unless(kJSPropertyAttributeNone)

    callback = Proc.new do |ctx, obj, this, len, args, exp|
      if(len > 0)
        tmp    = args.cast!('^{OpaqueJSValue=}')
        string = JSValueToStringCopy(ctx, tmp[0], exp)
        size = JSStringGetMaximumUTF8CStringSize(string)
        buffer = Pointer.new('c', size)
        ret = JSStringGetUTF8CString(string, buffer, size)
        JSStringRelease(string)

        ary = []
        (ret - 1).times { |i| ary << buffer[i] }
        puts ary.pack('c*')
      end
      nil
    end

    ctx = JSGlobalContextCreate(nil)
    global = JSContextGetGlobalObject(ctx)

    print = JSStringCreateWithUTF8CString("print")
    print_f = JSObjectMakeFunctionWithCallback(ctx, print, callback)
    JSObjectSetProperty(ctx, global, print, print_f, kJSPropertyAttributeNone, nil)
    JSStringRelease(print)

    source = JSStringCreateWithUTF8CString(program)
    exception = Pointer.new('^{OpaqueJSValue}')

    if(JSCheckScriptSyntax(ctx, source, nil, 0, exception))
      JSEvaluateScript(ctx, source, nil, nil, 0, exception)
    else
      puts "Error: Syntax error."
    end

    JSStringRelease(source)
    JSGlobalContextRelease(ctx)
  end
end

if($0 == __FILE__)
  program =<<EOS
  var sum = 0;

  for(var i = 1; i <= 10; i++) {
    sum += i;
  }
  print(sum);
  print("あいうえお");
EOS

  JSC.eval(program)
end
