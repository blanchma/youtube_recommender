import sys
import time
import MySQLdb
import scipy.io
from scipy.sparse import *
# phrase_ids = [57795, 39, 145537, 279434, 1002, 1203, 279433, 279432]
# video_id = 895343

conn = MySQLdb.connect (host = "99.104.219.59",
                        user = "mynewtv",
                        password = "vief2giac9is6h",
                        db = "mynewtv2")

matrices = []

def go():
  batches = 757
  for offset in range(batches):
    batch = offset + 1
    
    print "Adding batch %s of %s..." % (batch, batches)
    start = time.time()
    video_batch(offset)
    end = time.time() - start
    print "All done. Took %f seconds." % (end)
  
  start = time.time()  
  print "Stacking matrices..."
  M = final_matrix()
  end = time.time() - start
  print "Took %f seconds." % (end)
  
  print "Saving for matlab as videos_phrases.mat..."
  save(M)
  return M

def final_matrix():
  return vstack(matrices)

def save(matrix):
  scipy.io.savemat('videos_phrases.mat', mdict={'matrix':matrix})
  

def matrix(video_id, phrase_ids):
  data = [video_id] + [1 for x in range(len(phrase_ids))]
  row = [0 for x in range(len(phrase_ids)+1)]
  cols = [0] + phrase_ids
  
  shape = (1,469046)
  return coo_matrix((data,(row,cols)), shape=shape)

  
def video_batch(offset=0):
  cursor = conn.cursor()
  
  cursor.execute("SELECT id FROM videos ORDER BY ID LIMIT 1000 OFFSET %i" % (offset))
  rows = cursor.fetchall()
  for row in rows:
    video_id = row[0]
    # print "video: %s" % (video_id)
    phrase_ids = phrase_ids_for(video_id)
    # print "phrase_ids: %s" % (phrase_ids)
    matrices.append(matrix(video_id, phrase_ids))

def phrase_ids_for(video_id):
  cursor = conn.cursor()
  
  ids = []
  cursor.execute("SELECT phrase_id FROM phrases_videos WHERE video_id=%i" % (video_id))
  rows = cursor.fetchall()
  for row in rows:
    ids.append(row[0])
  return ids
