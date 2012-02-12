//
//  WFInstagramAPITests.m
//
//  Created by William Fleming on 1/13/12.
//

#import "WFInstagramAPITests.h"

@implementation WFInstagramAPITests

// less a test of InstagramAPI, and more a sanity check on my StaticStub
- (void)testStaticStubbing
{
  [WFInstagramAPI setClientId:@"bar"];
  
  StaticStub *stub = [StaticStub stubForClass:[WFInstagramAPI class]];
  [[[stub stub] andReturn:@"foo"] clientId];
  
  NSString *rv = [WFInstagramAPI clientId];
  STAssertEqualObjects(@"foo", rv, @"stubbed value should be return");
  
  [stub cancelStubs];
  
  rv = [WFInstagramAPI clientId];
  STAssertEqualObjects(@"bar", rv, @"stubbed value should be gone");
}

- (void) testGlobalErrorHandler {
  __block int blockCalled = 0;
  [WFInstagramAPI setGlobalErrorHandler:^(WFIGResponse* response) {
    blockCalled++;
  }];
  
  [StubNSURLConnection stubResponse:400
                               body:@"{\"meta\": {"
                                     "\"error_type\": \"OAuthParameterException\","
                                     "\"code\": 400,"
                                     "\"error_message\":\"full error message\""
                                     "}"
                             forURL:@"https://api.instagram.com/v1/users/self?access_token=testAccessToken"];
  
  [WFInstagramAPI currentUser];
  
  STAssertTrue((blockCalled > 0), @"error handler should have been called");
}

- (void) testCurrentUser {      
  WFIGUser *user = [WFInstagramAPI currentUser];
  
  STAssertTrue([user isKindOfClass:[WFIGUser class]], @"user was not fetched/inorrect class. user is %@", user);
  STAssertEqualObjects(user.username, @"thorisalaptop", @"bad parsing");
}

- (void) testBasicAuthURLGeneration {
  NSString *expected = @"https://api.instagram.com/oauth/authorize/?client_id=testClientId&redirect_uri=testRedirectURL&response_type=code&display=touch";
  STAssertEqualObjects(expected, [WFInstagramAPI authURL], @"expected \"%@\", but authURL was %@", expected, [WFInstagramAPI authURL]);
}

- (void) testAuthURLGenerationWithScope {
  [WFInstagramAPI setClientScope:@"comments+likes"];
  NSString *expected = @"https://api.instagram.com/oauth/authorize/?client_id=testClientId&redirect_uri=testRedirectURL&response_type=code&display=touch&scope=comments+likes";
  STAssertEqualObjects(expected, [WFInstagramAPI authURL], @"expected \"%@\", but authURL was %@", expected, [WFInstagramAPI authURL]);
}

- (void) testHttpGetConvenienceMethod {
  NSString *url = @"https://api.instagram.com/v1/endpoint/path?access_token=testAccessToken";
  [StubNSURLConnection stubResponse:200 body:@"foo" forURL:url];
  
  WFIGResponse *response = nil;
  STAssertNoThrow((response = [WFInstagramAPI get:@"/endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
  
  // results should be same without initial / on path
  response = nil;
  STAssertNoThrow((response = [WFInstagramAPI get:@"endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
}

- (void) testHttpPostConvenienceMethod {
  NSString *url = @"https://api.instagram.com/v1/endpoint/path";
  [StubNSURLConnection stubResponse:200 body:@"foo" forURL:url];
  
  WFIGResponse *response = nil;
  STAssertNoThrow((response = [WFInstagramAPI post:nil to:@"/endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
  
  // results should be same without initial / on path
  response = nil;
  STAssertNoThrow((response = [WFInstagramAPI post:nil to:@"endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
}

- (void) testHttpPutConvenienceMethod {
  NSString *url = @"https://api.instagram.com/v1/endpoint/path";
  [StubNSURLConnection stubResponse:200 body:@"foo" forURL:url];
  
  WFIGResponse *response = nil;
  STAssertNoThrow((response = [WFInstagramAPI put:nil to:@"/endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
  
  // results should be same without initial / on path
  response = nil;
  STAssertNoThrow((response = [WFInstagramAPI put:nil to:@"endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
}

- (void) testHttpDeleteConvenienceMethod {
  NSString *url = @"https://api.instagram.com/v1/endpoint/path?access_token=testAccessToken";
  [StubNSURLConnection stubResponse:200 body:@"foo" forURL:url];
  
  WFIGResponse *response = nil;
  STAssertNoThrow((response = [WFInstagramAPI delete:@"/endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
  
  // results should be same without initial / on path
  response = nil;
  STAssertNoThrow((response = [WFInstagramAPI delete:@"endpoint/path"]), @"fetch should work");
  STAssertTrue([response isKindOfClass:[WFIGResponse class]], @"response should be a WFIGResponse");
  STAssertTrue([response isSuccess], @"response should be a success");
  STAssertEqualObjects(@"foo", [response bodyAsString], @"body should be as expected");
}

//- (void) 


@end
