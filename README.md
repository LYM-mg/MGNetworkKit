# NetworkKit

This package was generated with the user's choices:
- Backend wrapped format: { "code": 0, "msg": "", "data": {...} } (choice A)
- Pagination fields: page / pageSize (choice D)

Quick notes:
- Macros require Swift 5.9 / Xcode 15 or newer.
- Replace MGNetworkConfig.default.baseURL with your real API base URL.
- The macro-generated request uses wrapped response format and will throw MGAPIError.business when code != 0.
- MGPager helper provided at Sources/NetworkKit/MGPager.swift implements refresh/loadNext/reset logic.

To build:
1. `swift build`
2. Or open in Xcode 15+

