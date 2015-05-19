# RealmTableViewFetch
Master-Detail UITableView with a FetchedResultsController using the Realm Database engine

# Setup

```
pod install
```

Open the xcworkspace file

# About the app

Displays a master-detail list of 'Items'

New items can be added with the + button.
Items can be deleted by left-swiping an item.

Each item contains a list of 'SubItems'. You can view these by tapping on an item.
New subitems can be added with the + button or removed by left-swiping them.


Tapping a subitem increments the number shown beneath. As the subitems are sorted by this number, tapping a subitem a few times may result in the item order changing.
