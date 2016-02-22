package word_count;

import java.util.*;
import java.io.*;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapred.*;
import org.apache.hadoop.util.*;

public class WordCount {

	public static class MapClass extends MapReduceBase implements Mapper<LongWritable, Text, Text, IntWritable> {
		
		Text outpKey = new Text();
		IntWritable outpVal = new IntWritable();
		
		public void map(LongWritable key, Text value, OutputCollector<Text, IntWritable> output, Reporter reporter) throws IOException {
			/* Split by all non-characters (a-z) */
			String[] tokens = (value.toString()).split("[^A-Za-z_']");
			
			/* Output lowercase tokens with length > 1 */
			for (int i=0; i<tokens.length; i++)
			{
				if((tokens[i]).length() <= 1)
					continue;
				outpKey.set(tokens[i].toLowerCase());
				outpVal.set(1);
				output.collect(outpKey, outpVal);
			}
		}
	}

	public static class Reduce extends MapReduceBase implements Reducer<Text, IntWritable, Text, IntWritable> {
		public void reduce(Text key, Iterator<IntWritable> values, OutputCollector<Text, IntWritable> output, Reporter reporter) throws IOException {
			int count = 0;
			
			/* Sum the total wordcount */
			while (values.hasNext()) 
			{
				count += values.next().get();
			}
			output.collect(key, new IntWritable(count));
		}
	}

	public static void main(String[] args) throws Exception {
		JobConf conf = new JobConf(WordCount.class);
		conf.setJobName("wordcount");

		conf.setOutputKeyClass(Text.class);
		conf.setOutputValueClass(IntWritable.class);

		conf.setMapperClass(MapClass.class);
		conf.setCombinerClass(Reduce.class);
		conf.setReducerClass(Reduce.class);

		conf.setInputFormat(TextInputFormat.class);
		conf.setOutputFormat(TextOutputFormat.class);

		FileInputFormat.setInputPaths(conf, new Path(args[0]));
		FileOutputFormat.setOutputPath(conf, new Path(args[1]));

		JobClient.runJob(conf);
    }
}


