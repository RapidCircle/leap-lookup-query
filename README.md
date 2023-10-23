About
Github Action that allows to query lookup data and return required value

The Lookup table is a configuration table which can be filled with required details.
It can be queried with single or multiple column values.

The response of the action will be a JSON object if FirstOrDefault flag is set.
If FirstOrDefault flag is not set, the action will return all the matching records in the form of JSON array. 
Even if there is only one item matching the query result, output will bwe JSON array with only one object