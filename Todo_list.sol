// SPDX-License-Identifier: Amir

pragma solidity >= 0.7.0 <= 0.8.0;


contract Todolist {


    enum status{started, done, accepted, failed}

    struct Task {
        uint id;
        uint createTime;
        uint16 deadline;
        address payable member;
        string describtion;
        status currentstatus;
    }

    Task[] public tasks;
    address payable public owner;
    uint public taskPrice = 10000000000000 wei;
    uint taskCode = 0;

    event CreateTask(uint _id, uint _createTime, uint16 _deadLine, address payable _member);

    constructor(){
        owner = payable(msg.sender);
    }

    function AddTask(uint16 _deadLine, string calldata _describtion) public payable {
        require(msg.value == taskPrice, "the entrace value is not correct");
        tasks.push(Task(taskCode, block.timestamp, _deadLine, payable(msg.sender), _describtion, status.started));
        taskCode++;
        emit CreateTask(taskCode, block.timestamp, _deadLine, payable(msg.sender));
    }

    function CheckTaskSituation(uint taskId) public view returns(status) {
        require(msg.sender == tasks[taskId].member, "The caller must be the owner of the task");
        return tasks[taskId].currentstatus;
    }

    function Changesituation(uint taskId) public returns(string memory){
        require(msg.sender == tasks[taskId].member, "The caller must be the owner of the task");
        require(tasks[taskId].currentstatus == status.started, "The current situation must be started");
        require(block.timestamp < ((86400 * tasks[taskId].deadline) + tasks[taskId].createTime));
        tasks[taskId].currentstatus = status.done;
        return "Situation changed successfully";
    }

    function Verify(bool verification, uint taskId) public {
        require(msg.sender == owner, "The caller must be owner");
        require(block.timestamp > ((86400 * tasks[taskId].deadline) + tasks[taskId].createTime), "Time is not over yet");
        if(tasks[taskId].currentstatus == status.started){
            tasks[taskId].currentstatus = status.failed;
            owner.transfer(taskPrice);
        }else{
            if(tasks[taskId].currentstatus == status.done && verification == true){
                tasks[taskId].currentstatus = status.accepted;
                (tasks[taskId].member).transfer(taskPrice);
            }else{
                tasks[taskId].currentstatus = status.failed;
                owner.transfer(taskPrice);
            }
        }
    }

    function ContractBalance() public view returns(uint){
        return address(this).balance;
    }


}