#!/usr/bin/env python
# coding: utf-8

# In[1]:


import mysql.connector
import pandas as pd
from flask import Flask, render_template, request, jsonify



pd.set_option('display.max_columns', None)

def fetch_data():
    cnx = mysql.connector.connect(
        host="23.23.4.75",
        user="han.sun@sciplatforms.com",
        password="r^Qx49%Yn3g5",
        database="customer", 
        auth_plugin='mysql_native_password'
    )

    cursor = cnx.cursor()
    query = """SELECT * FROM han_sun.NMR_Chemical_Shifts_of_Trace_Impurities;"""
    cursor.execute(query)

    data = pd.DataFrame(cursor.fetchall(), columns=[column[0] for column in cursor.description])
    cursor.close()
    cnx.close()
    return data


# In[3]:


# data = data.drop_duplicates()
# data


# In[ ]:


# def check_nmr(tablename):
#     if '1H NMR' in tablename:
#         return '1H NMR'
#     elif '13C NMR' in tablename:
#         return '13C NMR'
#     else:
#         return 'Other'
# data['NMR_Type'] = data['Tablename'].apply(check_nmr)
# data

# data['NMR_solvent'] = data['Tablename'].str.split().str[-1]

# data

# df = data
# import mysql.connector
# from sqlalchemy import create_engine
# def write_df_to_mysql(df, connection_str):
#     """
#     Write a pandas DataFrame to a MySQL table with user input for table name and if_exists option.

#     Args:
#     - df (pandas.DataFrame): The DataFrame to write to the database.
#     - connection_str (str): The connection string for the MySQL database.

#     Returns:
#     None
#     """
#     # Create the engine
#     engine = create_engine(connection_str)

#     # Request table name and if_exists option from the user
#     table_name = input("Enter the table name: ")
#     if_exists_option = input("Enter the if_exists option (append, replace, or fail): ")

#     # Write the DataFrame to the table
#     df.to_sql(table_name, engine, if_exists=if_exists_option, index=False)




# username = 'han.sun@sciplatforms.com'
# password = 'r^Qx49%Yn3g5'
# host = '23.23.4.75'
# port = '3306'
# database = 'han_sun'

# connection_str = f'mysql+pymysql://{username}:{password}@{host}:{port}/{database}'

# # Call the function to write the DataFrame to the MySQL table
# write_df_to_mysql(df, connection_str)

def clean_shift_data(df):
    df['upper_limit'] = df['shift']
    df['lower_limit'] = df['shift']

    for index, row in df.iterrows():
        if '-' in row['shift']:
            parts = list(map(float, row['shift'].split('-')))
            df.at[index, 'upper_limit'] = max(parts)
            df.at[index, 'lower_limit'] = min(parts)

    df['upper_limit'] = df['upper_limit'].astype(float)
    df['lower_limit'] = df['lower_limit'].astype(float)

    return df



def filter_data(df, nmr_solvent, nmr_type, solvent=None, shift=None):
    df = clean_shift_data(df)

    filtered_data = df[
        (df['NMR_solvent'] == nmr_solvent) & 
        (df['NMR_Type'] == nmr_type)
    ]

    if solvent:
        filtered_data = filtered_data[filtered_data['solvent'] == solvent]

    if shift:
        shift_type, shift_value = interpret_shift_input(shift)
        if shift_type == 'error':
            raise ValueError(shift_value)
        elif shift_type == 'single':
            shift_float = float(shift_value)
            filtered_data = filtered_data[(filtered_data['lower_limit'] <= shift_float) &
                                          (filtered_data['upper_limit'] >= shift_float)]
        elif shift_type == 'range':
            start, end = map(float, shift_value)
            # Check if any part of the data range is within the user-specified range
            filtered_data = filtered_data[((filtered_data['lower_limit'] >= start) & 
                                           (filtered_data['lower_limit'] <= end)) |
                                          ((filtered_data['upper_limit'] >= start) & 
                                           (filtered_data['upper_limit'] <= end))]

    return filtered_data.drop_duplicates()




# Function to interpret shift input (as previously defined)
def interpret_shift_input(shift_input):
    if '-' in shift_input:
        try:
            start, end = map(float, shift_input.split('-'))
            return 'range', (start, end)
        except ValueError:
            return 'error', "Invalid range format"
    else:
        try:
            value = float(shift_input)
            return 'single', value
        except ValueError:
            return 'error', "Invalid number format"

solvents_cache = None

def find_matching_solvents(user_input):
    global solvents_cache
    if solvents_cache is None:
        data_df = fetch_data()
        solvents_cache = data_df['solvent'].unique().tolist()
    
    matching_solvents = [solvent for solvent in solvents_cache if user_input.lower() in solvent.lower()]
    return matching_solvents




# # Example: Hardcoded inputs for testing
# nmr_solvent_input = 'CDCl3'  
# nmr_type_input = '1H NMR'       
# solvent_input = 'benzyl alcohol'      

# # Call the function with these inputs
# result_df = filter_data(data, nmr_solvent_input, nmr_type_input, solvent_input)

# # Display the result
# print(result_df)


# In[ ]:


app = Flask(__name__)
@app.route('/')
def home():
    nmr_solvents = ["CDCl3", "acetone-d6", "DMSO-d6", "CD3CN", "CD3OD" , "D2O"]  # Replace with real data
    nmr_types = ["1H NMR", "13C NMR"]  # Replace with real data
    return render_template('index.html', nmr_solvents=nmr_solvents, nmr_types=nmr_types)


@app.route('/refresh_solvents_cache', methods=['GET'])
def refresh_solvents_cache():
    global solvents_cache
    data_df = fetch_data()
    solvents_cache = data_df['solvent'].unique().tolist()
    return jsonify({"message": "Solvents cache refreshed successfully"})

@app.route('/suggest_solvent', methods=['GET'])
def suggest_solvent():
    user_input = request.args.get('input')
    if not user_input:
        return jsonify([]), 200

    matching_solvents = find_matching_solvents(user_input)
    return jsonify(matching_solvents)

# Add a new route for shift suggestions
@app.route('/suggest_shift', methods=['GET'])
def suggest_shift():
    user_input = request.args.get('input')
    if not user_input:
        return jsonify([]), 200

    matching_shifts = find_matching_shifts(user_input)
    return jsonify(matching_shifts)

def interpret_shift_input(shift_input):
    # Check if the input is a range (e.g., "7.28-7.24")
    if '-' in shift_input:
        try:
            start, end = map(float, shift_input.split('-'))
            return 'range', (start, end)
        except ValueError:
            # Handle the case where the range is not valid
            return 'error', "Invalid range format"
    else:
        try:
            value = float(shift_input)
            return 'single', value
        except ValueError:
            # Handle the case where the input is not a valid number
            return 'error', "Invalid number format"
        
@app.route('/filter_data', methods=['POST'])
def filter_data_route():
    try:
        data = request.get_json()
        nmr_type = data['nmr_type']
        nmr_solvent = data['nmr_solvent']
        solvent = data.get('solvent')  # Use .get to avoid KeyError
        shift = data.get('shift')      # Use .get to avoid KeyError

        # Ensure that either solvent or shift is provided, but not both
        if (solvent and shift) or (not solvent and not shift):
            return jsonify({'error': 'Please provide either solvent or shift, but not both'}), 400

        # Fetch the data from the database
        df = fetch_data()
        if df is None or df.empty:
            return jsonify({'error': 'No data available to filter.'}), 500

        # Filter the data based on solvent or shift
        if solvent:
            filtered_results = filter_data(df, nmr_solvent, nmr_type, solvent=solvent)
        else:  # shift is not None at this point
            filtered_results = filter_data(df, nmr_solvent, nmr_type, shift=shift)

        return jsonify(filtered_results.to_dict(orient='records'))

    except KeyError as e:
        return jsonify({'error': f'Missing data in request: {str(e)}'}), 400
    except Exception as e:
        return jsonify({'error': f'Error processing request: {str(e)}'}), 400


    # If you want to render a results page instead
#     return render_template('index.html', results=filtered_results.to_dict(orient='records'))

@app.route('/filter_data', methods=['POST'])
def api_filter_data():
    try:
        data = request.get_json()
        print("Received data:", data)  # For debugging purposes
        nmr_type = data['nmr_type']
        nmr_solvent = data['nmr_solvent']

        # Initialize filtered_results
        filtered_results = None

        # Check if solvent is in the data and process accordingly
        if 'solvent' in data and 'shift' not in data:
            filtered_results = filter_data(
                fetch_data(), 
                nmr_solvent, 
                nmr_type, 
                solvent=data['solvent']
            )
        # Check if shift is in the data and process accordingly
        elif 'shift' in data and 'solvent' not in data:
            filtered_results = filter_data(
                fetch_data(), 
                nmr_solvent, 
                nmr_type, 
                shift=data['shift']
            )
        else:
            # If neither solvent nor shift is provided, or both are provided
            return jsonify({'error': 'Please provide either solvent or shift, but not both'}), 400

        # Check if filtered_results is None, which means neither solvent nor shift was processed
        if filtered_results is None:
            return jsonify({'error': 'No valid search criteria provided'}), 400

        return jsonify(filtered_results.to_dict(orient='records'))

    except KeyError as e:
        return jsonify({'error': f'Missing data in request: {e}'}), 400
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': f'An error occurred: {str(e)}'}), 500


if __name__ == '__main__':
    with app.app_context():
        refresh_solvents_cache()
    app.run(debug=True)




