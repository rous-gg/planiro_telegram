pragma solidity ^0.4.2;

contract OrganizationRegistry {
  mapping (uint8 => uint256) public projectBalancesRegistry;
  mapping (uint8 => uint8)   public projectOwnersRegistry;
  mapping (uint8 => uint8)   public projectTasksRegistry;
  mapping (uint8 => uint8[]) public projectMembersRegistry;
  mapping (uint8 => uint8[]) public taskAssigneesRegistry;
  mapping (uint8 => uint256) public taskBalancesRegistry;
  mapping (uint8 => uint256) public userBalancesRegistry;

  function newProject(uint8 projectId, uint8 ownerId) public {
    projectOwnersRegistry[projectId] = ownerId;
    projectMembersRegistry[ownerId].push(projectId);
    projectBalancesRegistry[projectId] = 0;
  }

  function setBalance(uint8 projectId, uint256 balance) public {
    require(projectBalancesRegistry[projectId] == 0);
    projectBalancesRegistry[projectId] = balance;
  }

  function addMemberToProject(uint8 projectId, uint8 userId) returns(bool) {
    for(uint i = 0;i < projectMembersRegistry[userId].length; i++) {
      if (projectMembersRegistry[userId][i] == projectId) {
        return false;
      }
    }

    projectMembersRegistry[userId].push(projectId);
    return true;
  }

  function createProjectTask(uint8 projectId, uint8 taskId) public {
    projectTasksRegistry[taskId] = projectId;
  }

  function getUserProjects(uint8 userId) returns(uint8[]){
    return projectMembersRegistry[userId];
  }

  function newProjectTask(uint8 projectId, uint8 taskId) {
    projectTasksRegistry[taskId] = projectId;
  }

  function changeTaskAssignee(uint8 taskId, uint8 userId) {
    taskAssigneesRegistry[taskId] = userId;
  }

  function setTaskBalance(uint8 taskId, uint256 balance) {
    taskBalancesRegistry[taskId] = balance;
  }

  function acceptTask(uint8 taskId) {
    userId = taskAssigneesRegistry[taskI];

    if (userId) {
      balance = taskBalancesRegistry[taskId];
      if (balance) {
        amount = taskBalancesRegistry[taskId];
        userBalancesRegistry[userId] += taskBalancesRegistry[taskId];
        Transfer(taskId, userId, amount)
      }
    }
  }

  function getUserBalance(uint8 userId) returns(uint256) {
    return userBalancesRegistry[userId];
  }

  event Transfer(uint8 taskId, uint8 userId, uint256 amount);
}