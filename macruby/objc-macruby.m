/* filename : objc-macruby.m */
/* Compile: gcc objc-macruby.m -framework Foundation -framework MacRuby -fobjc-gc */
#import <Foundation/Foundation.h>
#import <MacRuby/MacRuby.h>

int main(void) {
  id ruby;

  ruby = [[MacRuby sharedRuntime] evaluateString:@"puts 'test'"];
  ruby = [[MacRuby sharedRuntime] evaluateFileAtPath:@"fib.rb"];

  NSNumber *num = [NSNumber numberWithInt: 31];
  NSLog(@"%@", [ruby performRubySelector:@selector(main) withArguments: (id)num, NULL]);
  return 0;
}
