import mpi.*;

public class BandwidthArray
{
private static final int LEN = 16777216,
                         WARM_UP = 50,
                         REPEAT  = 2000,
                         LOG2N_MAX = 1000000;

public static void main(String[] args) throws MPIException
{
    MPI.Init(args);

    if(MPI.COMM_WORLD.getSize() != 2)
    {
        System.err.println("This test is only for 2 processes.");
        MPI.COMM_WORLD.abort(1);
    }

    int j = 1;
    int log2nbyte;
    int rank = MPI.COMM_WORLD.getRank();

    /*
     * Sending a fragment of an array is optimized from version 1.9.
     * In previous versions of Java bindings the arrays are copied completely
     * although you only send a little fragment.
     */

    //byte[] sbuf = new byte[LEN]; // This is for 1.9+

    for(log2nbyte = 0; (log2nbyte <= LOG2N_MAX) && (j < LEN); log2nbyte++)
    {
        j = (1 << log2nbyte);
        byte[] sbuf = new byte[j]; // For prior versions (comment for 1.9)

        for(int i = 0; i < j; i++)
            sbuf[i] = (byte)'s';

        // Warm Up Loop
        for(int i = 0; i < WARM_UP; i++)
        {
            if(rank == 0)
            {
                MPI.COMM_WORLD.recv(sbuf, j, MPI.BYTE, 1, 998);
                MPI.COMM_WORLD.send(sbuf, j, MPI.BYTE, 1, 998);
            }
            else if(rank == 1)
            {
                MPI.COMM_WORLD.send(sbuf, j, MPI.BYTE, 0, 998);
                MPI.COMM_WORLD.recv(sbuf, j, MPI.BYTE, 0, 998);
            }
        }

        // Warm Up Loop
        double start = MPI.wtime();

        // Latency Calculation Loop
        for(int i = 0; i < REPEAT; i++)
        {
            if(rank == 0)
            {
                MPI.COMM_WORLD.send(sbuf, j, MPI.BYTE, 1, 998);
                MPI.COMM_WORLD.recv(sbuf, j, MPI.BYTE, 1, 998);
            }
            else if(rank == 1)
            {
                MPI.COMM_WORLD.recv(sbuf, j, MPI.BYTE, 0, 998);
                MPI.COMM_WORLD.send(sbuf, j, MPI.BYTE, 0, 998);
            }
        }

        double stop = MPI.wtime();
        double timed = stop - start;

        // End latency calculation loop
        double latency = (timed / (2 * REPEAT)) * 1000 * 1000;

        if(rank == 0)
        {
            double bandwidth = (8 * j) / (1024 * 1024 * latency / (1000*1000));
            System.out.printf("%d\t%.2f\t%.2f\n", j, latency, bandwidth);
        }
    }

    MPI.COMM_WORLD.barrier();
    MPI.Finalize();
}

} // BandwidthArray
