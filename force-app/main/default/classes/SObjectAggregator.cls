/**
 * Utility class containing a single public inner class (Node) and a single public
 * static method to help create top-down heirarchies of SObjects more than 1 level deep.
 *
 * @Author: Chad Pfrommer (Cloud Giants, Inc.) - chad@cloudgiants.com
 *
 * Copyright: Copyright 2016, Chad Pfrommer, Cloud Giants
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.If not, see <http://www.gnu.org/licenses/>.
 *
 * See <http://www.gnu.org/licenses/gpl.txt> for more info
 *
 */
public class SObjectAggregator {

    public class Node {
        public List<SObject> sObjects;
        public Node childNode;
        public String parentsideRelationshipName;
        public String childsideFieldName;
    }

    /**
     * Take a Node and generate a new List of SObjects with all descendent relationships
     * populated that are contained with the Node tree.
     */
    public static List<SObject> wireUpSObjectHeirarchy(Node topLevelNode) {
        if (topLevelNode.childNode == null) {
            // this is the end of our recursion.No children to add, so just return
            // the SObjects from this node.
            return topLevelNode.sObjects.clone();
        }
        else {

            Node childNode = topLevelNode.childNode;

            // Here's the recursive call:
            //first we go ahead and wire up things for the childNode by making a
            //recursive call to this method passing in the childNode
            List<SObject> wiredUpDescendents = wireUpSObjectHeirarchy(childNode);

            // now that we have all the descendents wired up, just get the current node's
            // SObjects with the wiredUpDescendents added to them
            List<SObject> parentSObjects = topLevelNode.sObjects;
            String parentsideRelationshipName = topLevelNode.parentsideRelationshipName;
            String childsideFieldName = childNode.childsideFieldName;
            return getParentObjectsWithChildObjectsOnThem(
                parentSObjects,
                wiredUpDescendents,
                parentsideRelationshipName,
                childsideFieldName);
        }
    }

    /**
     * Get a list of SObjects containing new instances for each parent SObject.Each
     * of those instances will have the child relationship populated with a clone of
     * each relevant child SObject found in the childSObjects list.
     */
    private static List<SObject> getParentObjectsWithChildObjectsOnThem(
        List<SObject> parentSObjects,
        List<SObject> childSObjects,
        String parentsideRelationshipName,
        String childsideFieldName)
    {

        List<SObject> newParentSObjectsList = new List<SObject>();

        // Loop through each parent and look for any child Objects that belong to the parent.
        // After we build the list of child objects for each parent, add the child objects on
        // to the parent SObject.
        for (SObject currentParentObject : parentSObjects) {

            List<SObject> childObjectsForCurrentParent = new List<SObject>();

            for (SObject currentChildObject : childSObjects) {
                if ((Id) currentChildObject.get(childsideFieldName) == (Id) currentParentObject.get('Id')) {
                    childObjectsForCurrentParent.add(currentChildObject);
                }
            }
            newParentSObjectsList.add(
                tackOnMasterDetailSObjects(
                    currentParentObject,
                    parentsideRelationshipName,
                    childObjectsForCurrentParent));
        }

        return newParentSObjectsList;
    }

    /**
     * Add a list of child SObjects to a target SObject using the specified relationshipName.
     *
     * This method just serializes the target SObject into JSON, modifies that JSON to add
     * the child objects in a way that the JSON deserialization method will understand, and
     * finally deserializes the new JSON into an SObject.
     */
    private static SObject tackOnMasterDetailSObjects(
        SObject targetSO,
        String relationshipName,
        List<SObject> realtedObjects)
    {

        String targetJson = JSON.serialize(targetSO);

        String realtedObjectsJson = '"' + relationshipName + '" : {';
        realtedObjectsJson += '"totalSize" : ' + realtedObjects.size() + ',';
        realtedObjectsJson += '"done" : true,';
        realtedObjectsJson += '"records" : ' + JSON.serialize(realtedObjects);
        realtedObjectsJson += '}';

        targetJson = targetJson.substring(0, targetJson.length()-1) + ',' + realtedObjectsJson + '}';
        System.debug(targetJson);

        return (SObject) JSON.deserialize(targetJson, SObject.class);
    }
}