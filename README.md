# OnTheMap
Udacity program App3

###Synopsis###
> This app allows users to login via his/her Udacity account or Facebook account. Once loged in, A tabView will be presented,
  with mapView and tableView as two main tabs. 
> * The mapView will be presented with pins dropped by other Udacity students. User can tap a pin to see detail info (other students name and provided link), 
  user will be directed to the linked webpage upon tapping the detail pin view. 
> * A list tableView contains the most recent Udacity students info, with students name on each cell. Upon touch, user will be directed to the linked webpage. 

> Once logged in, user can also post a pin onto the map. He/she will need to provide an address string, which will be reverse-geo-coded to generate
 geo-data (latitude and longitude). Once the geo-data has been successfully generated, user can post this location onto the server, along with a 
 webpage link.
  
###Main framework/technique used###
> * Udacity API for authentication and login
> * Facebook LoginKit to login via Facebook
> * Parse API for getting data and posting data
> * Apple MapKit to display drop pins and allow users explore different places
