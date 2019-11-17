# Popular GitHub Repositories

A native iOS app (swift) that shows the most popular GitHub repositories


## Requirements

- A native mobile app to show the list of the most popular GitHub repositories
- The list must be always up to date
- Select a repository from the list and, in a detail view, show more information about the selected repository (including number of stars)
- The detail view should automatically refresh its content
- Swift 4 or later
- Deployment target iOS 11
- Use UITableView or UICollectionView


## Remarks

- The original requirements requested the data to be update every second, but this is impossible because GitHub API only allows one unauthenticated request every 10 seconds.
- The API returns at most 30 results per page and a maximum of 1000 results.
- So, this app requests one page every 10 seconds, and if one repository is selected, its details are updated every 10 seconds.


## Instructions

- pod install
- Open the workspace file
- If SwiftyJSON doesn't compile because of swift version:
  select the Pods project, SwiftyJSON, Build Settings, Swift Language Version, change to the newest available version