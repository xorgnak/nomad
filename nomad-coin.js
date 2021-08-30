
var id = 'myspecialidformetheoneandonly'

var lastPeerId = null;
var peer = null; // own peer object
var conn = null;

peer = new Peer(id, {
    debug: 2
});

peer.on('open', function (id) {
    // Workaround for peer.reconnect deleting previous id
    if (peer.id === null) {
        console.log('Received null id from peer open');
        peer.id = lastPeerId;
    } else {
        lastPeerId = peer.id;
    }
    console.log('ID: ' + peer.id);
});
peer.on('connection', function (c) {
    c.on('open', function() {
        c.send('JOB,' + id + ",LOW");
    });
});
peer.on('disconnected', function () {
    console.log('Connection lost. Please reconnect');
    peer.id = lastPeerId;
    peer._lastServerId = lastPeerId;
    peer.reconnect();
});
peer.on('close', function() {
    conn = null;
    console.log('Connection destroyed');
});
peer.on('error', function (err) {
    console.log(err);
});

/**
 * Create the connection between the two Peers.
 *
 * Sets up callbacks that handle any events related to the
 * connection and data received on it.
 */
function mine(p) {
    // Close old connection
    if (conn) { conn.close(); }
    
    // Create connection to destination peer specified in the input field
    conn = peer.connect(p, {
        reliable: true
    });
    
    conn.on('open', function () {
        console.log("Connected to: " + conn.peer);
	// send job request
	socket.send("JOB," + id + ",LOW");
    });
    // Handle incoming data (messages only since this is the signal sender)
    conn.on('data', function (data) {
        if (data.includes("2.")) {
            //shows the server version in console
            console.log("The server is on version " + data);
            //shows in the console that it's requesting a new job
            console.log("Requesting a new job...\n");
            //asks for a new job
            conn.send("JOB," + id + ",LOW");
        }
        //this gets executed when the server sends something including "GOOD", which means the share was correct
        else if (event.data.includes("GOOD")) {
            //shows in the console that the share was correct
            console.log("and the share was correct!\n");
            //shows in the console that it's requesting a new job
            console.log("Requesting a new job...\n");
            //asks for a new job
            conn.send("JOB," + id + ",LOW");
        }
        //this gets executed when the server sends something including "BAD", which means the share was wrong
        else if (event.data.includes("BAD")) {
            //shows in thele that the share was wrong
            console.log("and the share was wrong...\n");
            //shows in the console that it's requesting a new job
            console.log("Requesting a new job...\n");
            //asks for a new job
            conn.send("JOB," + id + ",LOW");
        }
        //this gets executed when the server sends something which doesn't agree with the one's above, which means it's probably a job
        else {
            //shows in console that it recieved a new job, and shows the contents
            console.log("New job recieved! It contains: " + data);
            //splits the job in multiple pieces
            var job = data.split(",");
            //the difficulty is piece number 2 (counting from 0), and gets selected as a variable
            var difficulty = job[2];
            //looks at the time in milliseconds, and puts it in a variable
            var startingTime = performance.now();
            //it starts hashing
            for (result = 0; result < 100 * difficulty + 1; result++) {
                //makes a variable called "ducos1", and it contains a calculated SHA1 hash for job[0] + the result
                ducos1 = new Hashes.SHA1().hex(job[0] + result);
                //executes if the given job is the same as the calculated hash 
                if (job[1] === ducos1) {
                    //looks at the time in milliseconds, and puts it in a variable
                    var endingTime = performance.now();
                    //calculates the time it took to generate the hash, and divides it by 1000 (to convert it from milliseconds to seconds)
                    var timeDifference = (endingTime - startingTime) / 1000;
                    //calculates the hashrate with max 2 decimals
                    var hashrate = (result / timeDifference).toFixed(2);
                    //shows the hashrate in the console
                    console.log("The hashrate is " + hashrate + " H/s. Sending the result back to the server...");
                    //sends the result to the server
                    conn.send(result + "," + hashrate + ",nomad-coin-JS v0.0.0 by xorgnak," + id);
                    //breaks the script so it stops calculating the other possible hashes
                    break;
                }
            }
        }
	
    });
    conn.on('close', function () {
        console.log("Connected to: " + conn.peer);
    });
};
