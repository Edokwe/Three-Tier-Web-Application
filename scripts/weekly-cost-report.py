import boto3
import datetime
import csv
from botocore.exceptions import ClientError

def get_cost_report():
    ce = boto3.client('ce')
    
    # Define date range (Last 7 days)
    end = datetime.date.today()
    start = end - datetime.timedelta(days=7)
    
    try:
        response = ce.get_cost_and_usage(
            TimePeriod={
                'Start': start.strftime('%Y-%m-%d'),
                'End': end.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
            Metrics=['UnblendedCost'],
            GroupBy=[
                {'Type': 'DIMENSION', 'Key': 'SERVICE'},
                {'Type': 'DIMENSION', 'Key': 'LINKED_ACCOUNT'}
            ]
        )
        
        results = []
        for result in response['ResultsByTime']:
            date = result['TimePeriod']['Start']
            for group in result['Groups']:
                service = group['Keys'][0]
                account = group['Keys'][1]
                cost = float(group['Metrics']['UnblendedCost']['Amount'])
                results.append([date, account, service, cost])
                
        return results
        
    except ClientError as e:
        print(f"Error fetching cost data: {e}")
        return []

def main():
    print("Fetching AWS Cost Report...")
    data = get_cost_report()
    
    if not data:
        print("No cost data found or error occurred.")
        return

    filename = f"cost-report-{datetime.date.today()}.csv"
    with open(filename, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Date', 'Account', 'Service', 'Cost'])
        writer.writerows(data)
        
    print(f"Report saved to {filename}")

if __name__ == "__main__":
    main()
